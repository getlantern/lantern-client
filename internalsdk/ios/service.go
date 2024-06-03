package ios

// var (
// 	clEventual = eventual.NewValue()
// 	startOnce  sync.Once
// )

// type LanternService struct {
// 	memoryAvailable int64
// 	sessionModel    *internalsdk.SessionModel
// }

// func newService(sessionModel *internalsdk.SessionModel) *LanternService {
// 	return &LanternService{
// 		sessionModel: sessionModel,
// 	}
// }

// func (s *LanternService) Start(configDir string, locale string, settings internalsdk.Settings) {
// 	optimizeMemoryUsage(&s.memoryAvailable)
// 	logging.EnableFileLogging(common.DefaultAppName, filepath.Join(configDir, "logs"))
// 	session := internalsdk.NewPanickingSession(s.sessionModel)
// 	startOnce.Do(func() {
// 		go run(configDir, locale, settings, session)
// 	})
// }

// func run(configDir, locale string, settings internalsdk.Settings, session internalsdk.PanickingSession) {
// 	log.Debugf("Starting lantern: configDir %s locale %s sticky config %t",
// 		configDir, locale, settings.StickyConfig())

// 	// Set home directory prior to starting Lantern
// 	appdir.SetHomeDir(configDir)

// 	_, err := flashlight.New(
// 		common.DefaultAppName,
// 		common.ApplicationVersion,
// 		common.RevisionDate,
// 		configDir,                    // place to store lantern configuration
// 		false,                        // don't enable vpn mode for iOS (VPN is handled in the Swift layer)
// 		func() bool { return false }, // always connected
// 		func() bool { return true },
// 		func() bool { return false }, // do not proxy private hosts on iOS
// 		func() bool { return true },  // auto report
// 		map[string]interface{}{},
// 		func(cfg *config.Global, src config.Source) {
// 			b, err := yaml.Marshal(cfg)
// 			if err != nil {
// 				log.Errorf("Unable to marshal user config: %v", err)
// 			} else {
// 				log.Debugf("Got new global config %s", string(b))
// 			}
// 		}, // onConfigUpdate
// 		func(proxies []bandit.Dialer, src config.Source) {

// 		}, // onProxiesUpdate
// 		internalsdk.NewUserConfig(session),
// 		internalsdk.NewStatsTracker(session),
// 		session.IsProUser,
// 		func() string { return "" }, // only used for desktop
// 		func(addr string) (string, error) {
// 			return "", nil
// 		},
// 		func(category, action, label string) {},
// 	)
// 	if err != nil {
// 		log.Fatalf("failed to create new instance of flashlight: %v", err)
// 	}
// }

//	func HTTPProxyPort() int {
//		if addr, ok := client.Addr(6 * time.Second); ok {
//			if _, p, err := net.SplitHostPort(addr.(string)); err == nil {
//				port, _ := strconv.Atoi(p)
//				return port
//			}
//		}
//		log.Errorf("Couldn't retrieve HTTP proxy addr in time")
//		return 0
//	}
func main() {

}
