module github.com/getlantern/android-lantern

go 1.16

require (
	github.com/cloudfoundry/jibber_jabber v0.0.0-20151120183258-bcc4c8345a21 // indirect
	github.com/getlantern/appdir v0.0.0-20200615192800-a0ef1968f4da
	github.com/getlantern/autoupdate v0.0.0-20180719190525-a22eab7ded99
	github.com/getlantern/dnsgrab v0.0.0-20211216020425-5d5e155a01a8
	github.com/getlantern/errors v1.0.1
	github.com/getlantern/eventual v1.0.0
	github.com/getlantern/flashlight v0.0.0-20220112145947-dc0fc0f399f7
	github.com/getlantern/go-update v0.0.0-20190510022740-79c495ab728c // indirect
	github.com/getlantern/golog v0.0.0-20210606115803-bce9f9fe5a5f
	github.com/getlantern/idletiming v0.0.0-20201229174729-33d04d220c4e
	github.com/getlantern/ipproxy v0.0.0-20201020142114-ed7e3a8d5d87
	github.com/getlantern/memhelper v0.0.0-20181113170838-777ea7552231
	github.com/getlantern/mtime v0.0.0-20200417132445-23682092d1f7
	github.com/getlantern/netx v0.0.0-20211206143627-7ccfeb739cbd
	github.com/getlantern/packetforward v0.0.0-20201001150407-c68a447b0360
	github.com/getlantern/protected v0.0.0-20210826185807-3b63e18e28bb
	github.com/getlantern/proxy v0.0.0-20210806161026-8f52aabf6214 // indirect
	github.com/getlantern/replica v0.7.1-0.20220111005757-1b4cc00cbce0
	github.com/gorilla/mux v1.8.0
	github.com/kardianos/osext v0.0.0-20190222173326-2bc1f35cddc0 // indirect
	github.com/kr/binarydist v0.1.0 // indirect
	github.com/stretchr/testify v1.7.0
	github.com/vishvananda/netns v0.0.0-20210104183010-2eb08e3e575f // indirect
	golang.org/x/net v0.0.0-20211111160137-58aab5ef257a
	golang.org/x/sys v0.0.0-20211216021012-1d35b9e2eb4e // indirect
	golang.org/x/tools v0.1.8 // indirect
	nhooyr.io/websocket v1.8.7
)

replace github.com/lucas-clemente/quic-go => github.com/getlantern/quic-go v0.0.0-20211103152344-c9ce5bfd4854

replace github.com/refraction-networking/utls => github.com/getlantern/utls v0.0.0-20211116192935-1abdc4b1acab

replace github.com/anacrolix/go-libutp => github.com/getlantern/go-libutp v1.0.3-0.20210202003624-785b5fda134e

// git.apache.org isn't working at the moment, use mirror (should probably switch back once we can)
replace git.apache.org/thrift.git => github.com/apache/thrift v0.0.0-20180902110319-2566ecd5d999

replace github.com/keighl/mandrill => github.com/getlantern/mandrill v0.0.0-20191024010305-7094d8b40358

replace github.com/google/netstack => github.com/getlantern/netstack v0.0.0-20210430190606-84f1a4e5b695

//replace github.com/getlantern/yinbi-server => ../yinbi-server

//replace github.com/getlantern/auth-server => ../auth-server

//replace github.com/getlantern/lantern-server => ../lantern-server

// XXX <15-10-21, soltzen> Using our own crawshaw.io/sqlite fork mainly for:
// - https://github.com/crawshaw/sqlite/pull/112
// - https://github.com/crawshaw/sqlite/pull/103
// - https://github.com/getlantern/sqlite/pull/4
replace crawshaw.io/sqlite => github.com/getlantern/sqlite v0.3.3-0.20211018070028-9eeb5042b175

replace github.com/eycorsican/go-tun2socks => github.com/getlantern/go-tun2socks v1.16.12-0.20201218023150-b68f09e5ae93

// v0.5.6 has a security issue and using require leaves a reference to it in go.sum
replace github.com/ulikunitz/xz => github.com/ulikunitz/xz v0.5.8
