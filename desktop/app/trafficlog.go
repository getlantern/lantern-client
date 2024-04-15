package app

import (
	stderrors "errors"
	"io"
	"io/ioutil"
	"os"
	"os/user"
	"path/filepath"
	"strings"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/errors"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/i18n"
	"github.com/getlantern/trafficlog"
	"github.com/getlantern/trafficlog-flashlight/tlproc"
	"github.com/getlantern/yaml"

	"github.com/getlantern/lantern-client/desktop/features"
	"github.com/getlantern/lantern-client/desktop/icons"
)

const (
	trafficlogStartTimeout        = 5 * time.Second
	trafficlogRequestTimeout      = time.Second
	trafficlogDefaultSaveDuration = 5 * time.Minute

	// This file, in the config directory, holds information about installation failures.
	tlInstallFailuresFilename = "tl_install_failures.yaml"

	yamlableTimeFormat = time.RFC3339
)

var errTrafficLogDisabled = errors.New("traffic log is disabled")

type yamlableTime time.Time

func yamlableNow() *yamlableTime {
	yt := yamlableTime(time.Now())
	return &yt
}

func (yt *yamlableTime) GetYAML() (tag string, value interface{}) {
	if yt == nil {
		return "", time.Time(yamlableTime{}).Format(yamlableTimeFormat)
	}
	return "", time.Time(*yt).Format(yamlableTimeFormat)
}

func (yt *yamlableTime) SetYAML(tag string, value interface{}) bool {
	valueString, ok := value.(string)
	if !ok {
		return false
	}
	t, err := time.Parse(yamlableTimeFormat, valueString)
	if err != nil {
		return false
	}
	*yt = yamlableTime(t)
	return true
}

func (yt *yamlableTime) IsZero() bool {
	if yt == nil {
		return true
	}
	return time.Time(*yt).IsZero()
}

func (yt *yamlableTime) SetToZero() {
	*yt = yamlableTime{}
}

func (yt *yamlableTime) timeSince() time.Duration {
	return time.Since(time.Time(*yt))
}

// A YAML file in which we store data about traffic log installation failures.
type tlInstallFailuresFile struct {
	LastFailed, LastDenial *yamlableTime
	Failures, Denials      int

	path string
}

// If the file does not exist, this function returns a default value, pointed at the input path.
func openTLInstallFailuresFile(path string) (*tlInstallFailuresFile, error) {
	f := new(tlInstallFailuresFile)
	b, err := ioutil.ReadFile(path)
	if stderrors.Is(err, os.ErrNotExist) {
		return &tlInstallFailuresFile{&yamlableTime{}, &yamlableTime{}, 0, 0, path}, nil
	} else if err != nil {
		return nil, errors.New("failed to read file: %v", err)
	}
	if err := yaml.Unmarshal(b, f); err != nil {
		return nil, errors.New("failed to unmarshal file: %v", err)
	}
	f.path = path
	return f, nil
}

// Write changes to disk.
func (f tlInstallFailuresFile) flushChanges() error {
	b, err := yaml.Marshal(f)
	if err != nil {
		return errors.New("failed to marshal: %v", err)
	}
	if err := ioutil.WriteFile(f.path, b, 0644); err != nil {
		return errors.New("failed to write file: %v", err)
	}
	return nil
}

func trafficlogInstallPrompt() string {
	translatedAppName := i18n.T(strings.ToUpper(common.DefaultAppName))
	return i18n.T("BACKEND_INSTALL_DIAGNOSTIC_TOOLS", translatedAppName, translatedAppName)
}

// getCapturedPackets writes all packets captured during the input duration. The traffic log must be
// enabled. The packets are written to w in pcapng format.
func (app *App) getCapturedPackets(w io.Writer) error {
	app.trafficLogLock.Lock()
	app.proxiesLock.RLock()
	defer app.trafficLogLock.Unlock()
	defer app.proxiesLock.RUnlock()

	if app.trafficLog == nil {
		return errTrafficLogDisabled
	}
	for _, p := range app.proxies {
		if err := app.trafficLog.SaveCaptures(p.Addr(), app.captureSaveDuration); err != nil {
			return errors.New("failed to save captures for %s: %v", p.Name(), err)
		}
	}
	if err := app.trafficLog.WritePcapng(w); err != nil {
		return errors.New("failed to write saved packets: %v", err)
	}
	return nil
}

func (app *App) trafficLogOpts() (*config.TrafficLogOptions, error) {
	opts := new(config.TrafficLogOptions)
	if err := app.flashlight.Client().FeatureOptions(config.FeatureTrafficLog, opts); err != nil {
		log.Errorf("failed to unmarshal traffic log options: %v", err)
		if features.EnableTrafficlog {
			log.Debug("using forced traffic log options")
			return features.ForcedTrafficLogOptions, nil
		}
		return nil, err
	}
	return opts, nil
}

// This should be run in an independent routine as it may need to install and block for a
// user-action granting permissions.
func (app *App) toggleTrafficLog(enable bool) {
	app.trafficLogLock.Lock()
	app.proxiesLock.RLock()
	defer app.trafficLogLock.Unlock()
	defer app.proxiesLock.RUnlock()

	var (
		opts *config.TrafficLogOptions
		err  error
	)
	if enable {
		opts, err = app.trafficLogOpts()
		if err != nil {
			return
		}
	}

	switch {
	case enable && app.trafficLog == nil:
		installDir := appdir.General("Lantern")
		log.Debugf("Installing traffic log if necessary in %s", installDir)
		if err := app.tryTrafficLogInstall(installDir, *opts); err != nil {
			log.Errorf("Failed to install traffic log: %v", err)
			return
		}
		log.Debug("Turning traffic log on")
		if err := app.turnOnTrafficLog(installDir, *opts); err != nil {
			log.Errorf("Failed to turn on traffic log: %v", err)
		}
		app.captureSaveDuration = opts.CaptureSaveDuration
		if app.captureSaveDuration == 0 {
			app.captureSaveDuration = trafficlogDefaultSaveDuration
		}

	case enable && app.trafficLog != nil:
		err := app.trafficLog.UpdateBufferSizes(opts.CaptureBytes, opts.SaveBytes)
		if err != nil {
			log.Debugf("Failed to update traffic log buffer sizes: %v", err)
		}

	case !enable && app.trafficLog != nil:
		log.Debug("Turning traffic log off")
		if err := app.trafficLog.Close(); err != nil {
			log.Errorf("Failed to close traffic log (this will create a memory leak): %v", err)
		}
		app.trafficLog = nil
	}
}

// Not concurrency-safe. Intended to serve as a helper to configureTrafficLog.
func (app *App) tryTrafficLogInstall(installDir string, opts config.TrafficLogOptions) error {
	u, err := user.Current()
	if err != nil {
		return errors.New("failed to look up current user for traffic log install: %v", err)
	}

	var iconFile string
	icon, err := icons.Asset(appIcon("connected"))
	if err != nil {
		log.Debugf("Unable to load prompt icon during traffic log install: %v", err)
	} else {
		iconFile = filepath.Join(os.TempDir(), "lantern_tlinstall.ico")
		if err := ioutil.WriteFile(iconFile, icon, 0644); err != nil {
			// Failed to save the icon file, just use no icon.
			iconFile = ""
		}
	}

	// Default for these options is to ask a single time.
	if opts.FailuresThreshold == 0 {
		opts.FailuresThreshold = 1
	}
	if opts.UserDenialThreshold == 0 {
		opts.UserDenialThreshold = 1
	}

	failuresFilePath := filepath.Join(app.configDir, tlInstallFailuresFilename)
	failuresFile, err := openTLInstallFailuresFile(failuresFilePath)
	if err != nil {
		return errors.New("unable to open traffic log install-failures file: %v", err)
	}
	defer func() { failuresFile.flushChanges() }()
	if !failuresFile.LastFailed.IsZero() &&
		failuresFile.LastFailed.timeSince() > opts.TimeBeforeFailureReset {
		failuresFile.Failures = 0
		failuresFile.LastFailed.SetToZero()
	}
	if !failuresFile.LastDenial.IsZero() &&
		failuresFile.LastDenial.timeSince() > opts.TimeBeforeDenialReset {
		failuresFile.Denials = 0
		failuresFile.LastDenial.SetToZero()
	}
	if failuresFile.Failures >= opts.FailuresThreshold {
		return errors.New(
			"failures (%d) already meets threshold (%d)",
			failuresFile.Failures, opts.FailuresThreshold,
		)
	}
	if failuresFile.Denials >= opts.UserDenialThreshold {
		return errors.New(
			"user denials (%d) already meets threshold (%d)",
			failuresFile.Denials, opts.UserDenialThreshold,
		)
	}
	if !failuresFile.LastFailed.IsZero() {
		if opts.WaitTimeSinceFailedInstall == 0 {
			return errors.New("aborting: install previously failed")
		}
		if failuresFile.LastFailed.timeSince() < opts.WaitTimeSinceFailedInstall {
			return errors.New(
				"aborting: last failed %v ago, wait time is %v",
				failuresFile.LastFailed.timeSince(), opts.WaitTimeSinceFailedInstall,
			)
		}
	}

	// Note that this is a no-op if the traffic log is already installed.
	installOpts := tlproc.InstallOptions{Overwrite: opts.Reinstall}
	err = tlproc.Install(installDir, u.Username, trafficlogInstallPrompt(), iconFile, &installOpts)
	if err != nil {
		failuresFile.LastFailed = yamlableNow()
		failuresFile.Failures++
		if stderrors.Is(err, tlproc.ErrPermissionDenied) {
			failuresFile.Denials++
			failuresFile.LastDenial = yamlableNow()
		}
		return errors.Wrap(err)
	}
	return nil
}

// Not concurrency-safe. Intended to serve as a helper to configureTrafficLog.
func (app *App) turnOnTrafficLog(installDir string, opts config.TrafficLogOptions) error {
	var err error
	app.trafficLog, err = tlproc.New(
		opts.CaptureBytes,
		opts.SaveBytes,
		installDir,
		&tlproc.Options{
			Options: trafficlog.Options{
				MutatorFactory: new(trafficlog.AppStripperFactory),
			},
			StartTimeout:   trafficlogStartTimeout,
			RequestTimeout: trafficlogRequestTimeout,
		})
	if err != nil {
		return errors.Wrap(err)
	}
	// These goroutines will close when the traffic log is closed.
	go func() {
		for err := range app.trafficLog.Errors() {
			log.Debugf("Traffic log error: %v", err)
		}
	}()
	go func() {
		for stats := range app.trafficLog.Stats() {
			log.Debugf("Traffic log stats: %v", stats)
		}
	}()
	proxyAddrs := []string{}
	for _, p := range app.proxies {
		proxyAddrs = append(proxyAddrs, p.Addr())
	}
	if err := app.trafficLog.UpdateAddresses(proxyAddrs); err != nil {
		app.trafficLog.Close()
		app.trafficLog = nil
		return errors.New("failed to start traffic logging for proxies: %v", err)
	}
	return nil
}
