package app

import (
	"io"
	"math"
	"strconv"

	"github.com/getlantern/flashlight/v7/bandit"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/flashlight/v7/pro"

	"github.com/getlantern/flashlight/v7/util"
	"github.com/getlantern/osversion"
)

var (
	// Number of runes(code points - characters of variable length bytes depending on encoding)
	// allowed in fileName length
	maxNameLength uint = 60
	// Number of bytes allowed in file attachment (8 mb)
	maxFileSize float64 = 8 * math.Pow(10, 6)
)

type issueReporter struct {
	settings           *Settings
	getCapturedPackets func(io.Writer) error
	getProxies         func() []bandit.Dialer
}

type issueMessage struct {
	Email     string `json:"email,omitempty"`
	IssueType string `json:"issueType,omitempty"`
	Note      string `json:"note,omitempty"`
	File      string `json:"file,omitempty"`
	FileName  string `json:"fileName,omitempty"`
	// If true, diagnostics will be run and a report will be attached
	RunDiagnostics bool `json:"runDiagnostics,omitempty"`
	// DiagnosticsYAML is a YAML-encoded diagnostics report.
	DiagnosticsYAML []byte
	// ProxyCapture is a gzipped pcapng file related to diagnostics.
	ProxyCapture []byte
}

// newIssueReporter creates a new issue reporter that can be used to send issue reports
// to the Lantern team.
func newIssueReporter(settings *Settings, getCapturedPackets func(io.Writer) error,
	getProxies func() []bandit.Dialer) *issueReporter {
	return &issueReporter{
		settings:           settings,
		getCapturedPackets: getCapturedPackets,
		getProxies:         getProxies,
	}
}

// sendIssueReport creates an issue report from the given UI message and submits it to
// lantern-cloud/issue service, which is then forwarded to the ticket system via API
func (reporter *issueReporter) sendIssueReport(msg *issueMessage) error {

	if msg.RunDiagnostics {
		var err error
		msg.DiagnosticsYAML, msg.ProxyCapture, err = reporter.runDiagnostics()
		if err != nil {
			log.Errorf("error running diagnostics: %v", err)
		}
	}

	settings := reporter.settings
	uc := common.NewUserConfigData(
		common.DefaultAppName,
		settings.GetDeviceID(),
		settings.GetUserID(),
		settings.GetToken(),
		nil,
		settings.GetLanguage(),
	)

	issueTypeInt, err := strconv.Atoi(msg.IssueType)
	if err != nil {
		return err
	}
	subscriptionLevel := "free"
	if isPro, _ := pro.IsProUser(settings); isPro {
		subscriptionLevel = "pro"
	}
	var osVersion string
	osVersion, err = osversion.GetHumanReadable()
	if err != nil {
		log.Errorf("Unable to get version: %v", err)
	}
	attachments := []*issue.Attachment{}
	// Include screenshot if the user attached it to the report
	fileContent, fileName := msg.File, msg.FileName
	if fileContent != "" && fileName != "" {
		fileName = util.TrimStringAsRunes(maxNameLength, fileName, true)
		fileName = util.SanitizePathString(fileName)

		byteLen := float64(len(fileContent))
		if byteLen <= maxFileSize {
			attachments = append(attachments, &issue.Attachment{
				Data: []byte(fileContent),
				Name: fileName,
			})
		} else {
			log.Errorf("file %s too large", fileName)
		}
	}

	if msg.DiagnosticsYAML != nil {
		attachments = append(attachments, &issue.Attachment{
			Name: "diagnostics.yaml",
			Data: msg.DiagnosticsYAML,
		})
	}
	if msg.ProxyCapture != nil {
		attachments = append(attachments, &issue.Attachment{
			Name: "proxy_capture.zip",
			Data: msg.ProxyCapture,
		})
	}

	return issue.SendReport(
		uc,
		issueTypeInt,
		msg.Note,
		subscriptionLevel,
		msg.Email,
		ApplicationVersion,
		"",
		"",
		osVersion,
		attachments,
	)
}
