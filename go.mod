module github.com/getlantern/android-lantern

go 1.15

require (
	github.com/getlantern/appdir v0.0.0-20200615192800-a0ef1968f4da
	github.com/getlantern/autoupdate v0.0.0-20180719190525-a22eab7ded99
	github.com/getlantern/dnsgrab v0.0.0-20210830103124-84f280b82954
	github.com/getlantern/errors v1.0.1
	github.com/getlantern/eventual v1.0.0
	github.com/getlantern/flashlight v0.0.0-20210827120602-cc390f17f62a
	github.com/getlantern/go-update v0.0.0-20190510022740-79c495ab728c // indirect
	github.com/getlantern/golog v0.0.0-20210606115803-bce9f9fe5a5f
	github.com/getlantern/idletiming v0.0.0-20201229174729-33d04d220c4e
	github.com/getlantern/ipproxy v0.0.0-20201020142114-ed7e3a8d5d87
	github.com/getlantern/memhelper v0.0.0-20181113170838-777ea7552231
	github.com/getlantern/mtime v0.0.0-20200417132445-23682092d1f7
	github.com/getlantern/netx v0.0.0-20210813193214-fc6827f83767
	github.com/getlantern/packetforward v0.0.0-20201001150407-c68a447b0360
	github.com/getlantern/protected v0.0.0-20210826185807-3b63e18e28bb
	github.com/go-stack/stack v1.8.1 // indirect
	github.com/kardianos/osext v0.0.0-20190222173326-2bc1f35cddc0 // indirect
	github.com/kr/binarydist v0.1.0 // indirect
	github.com/stretchr/testify v1.7.0
	github.com/vishvananda/netns v0.0.0-20210104183010-2eb08e3e575f // indirect
	golang.org/x/mobile v0.0.0-20210831184057-f7a629369e7a // indirect
	golang.org/x/mod v0.5.0 // indirect
	golang.org/x/net v0.0.0-20210825183410-e898025ed96a
	golang.org/x/sys v0.0.0-20210831042530-f4d43177bf5e // indirect
	golang.org/x/tools v0.1.5 // indirect
	nhooyr.io/websocket v1.8.7
)

replace github.com/lucas-clemente/quic-go => github.com/getlantern/quic-go v0.7.1-0.20210422183034-b5805f4c233b

replace github.com/refraction-networking/utls => github.com/getlantern/utls v0.0.0-20200903013459-0c02248f7ce1

replace github.com/anacrolix/go-libutp => github.com/getlantern/go-libutp v1.0.3-0.20210202003624-785b5fda134e

// git.apache.org isn't working at the moment, use mirror (should probably switch back once we can)
replace git.apache.org/thrift.git => github.com/apache/thrift v0.0.0-20180902110319-2566ecd5d999

replace github.com/keighl/mandrill => github.com/getlantern/mandrill v0.0.0-20191024010305-7094d8b40358

replace github.com/google/netstack => github.com/getlantern/netstack v0.0.0-20210430190606-84f1a4e5b695

//replace github.com/getlantern/yinbi-server => ../yinbi-server

//replace github.com/getlantern/auth-server => ../auth-server

//replace github.com/getlantern/lantern-server => ../lantern-server

// For https://github.com/crawshaw/sqlite/pull/112 and https://github.com/crawshaw/sqlite/pull/103.
replace crawshaw.io/sqlite => github.com/getlantern/sqlite v0.3.3-0.20210215090556-4f83cf7731f0

replace github.com/eycorsican/go-tun2socks => github.com/getlantern/go-tun2socks v1.16.12-0.20201218023150-b68f09e5ae93
