module github.com/getlantern/android-lantern/desktop

go 1.21

toolchain go1.21.3

replace github.com/getlantern/flashlight/v7 => ../../flashlight

replace github.com/lucas-clemente/quic-go => github.com/getlantern/quic-go v0.31.1-0.20230104154904-d810c964a217

replace github.com/elazarl/goproxy => github.com/getlantern/goproxy v0.0.0-20220805074304-4a43a9ed4ec6

replace github.com/Jigsaw-Code/outline-ss-server => github.com/getlantern/lantern-shadowsocks v1.3.6-0.20230301223223-150b18ac427d

replace github.com/keighl/mandrill => github.com/getlantern/mandrill v0.0.0-20221004112352-e7c04248adcb

require (
	github.com/anacrolix/generics v0.0.0-20230911070922-5dd7545c6b13
	github.com/getlantern/appdir v0.0.0-20200615192800-a0ef1968f4da
	github.com/getlantern/dhtup v0.0.0-20230623111555-a085ca76f0cd
	github.com/getlantern/errors v1.0.3
	github.com/getlantern/eventual v1.0.0
	github.com/getlantern/filepersist v0.0.0-20210901195658-ed29a1cb0b7c
	github.com/getlantern/flashlight/v7 v7.6.19
	github.com/getlantern/golog v0.0.0-20230503153817-8e72de7e0a65
	github.com/getlantern/i18n v0.0.0-20181205222232-2afc4f49bb1c
	github.com/getlantern/lantern-desktop v0.0.0-20231101233102-6a3b1befc089
	github.com/getlantern/launcher v0.0.0-20230622120034-fe87f9bff286
	github.com/getlantern/memhelper v0.0.0-20220104170102-df557102babd
	github.com/getlantern/notifier v0.0.0-20220715102006-f432f7e83f94
	github.com/getlantern/profiling v0.0.0-20160317154340-2a15afbadcff
	github.com/getlantern/sysproxy v0.0.0-20230319110552-63a8cacb7b9b
	github.com/getlantern/systray v1.2.2
	github.com/getlantern/timezone v0.0.0-20210901200113-3f9de9d360c9
	github.com/getlantern/trafficlog-flashlight v1.0.4
	github.com/getlantern/yaml v0.0.0-20190801163808-0c9bb1ebf426
	github.com/getsentry/sentry-go v0.25.0
	github.com/google/uuid v1.4.0
	github.com/gorilla/websocket v1.5.0
	github.com/stretchr/testify v1.8.4
	golang.org/x/sys v0.14.0
)

require (
	filippo.io/edwards25519 v1.0.0 // indirect
	git.torproject.org/pluggable-transports/goptlib.git v1.3.0 // indirect
	github.com/Jigsaw-Code/outline-ss-server v1.4.0 // indirect
	github.com/OperatorFoundation/Replicant-go/Replicant/v3 v3.0.23 // indirect
	github.com/OperatorFoundation/Starbridge-go/Starbridge/v3 v3.0.17 // indirect
	github.com/OperatorFoundation/ghostwriter-go v1.0.6 // indirect
	github.com/OperatorFoundation/go-bloom v1.0.1 // indirect
	github.com/OperatorFoundation/go-shadowsocks2 v1.2.1 // indirect
	github.com/PuerkitoBio/goquery v1.8.1 // indirect
	github.com/RoaringBitmap/roaring v1.2.3 // indirect
	github.com/Yawning/chacha20 v0.0.0-20170904085104-e3b1f968fc63 // indirect
	github.com/aead/ecdh v0.2.0 // indirect
	github.com/ajwerner/btree v0.0.0-20211221152037-f427b3e689c0 // indirect
	github.com/alecthomas/atomic v0.1.0-alpha2 // indirect
	github.com/anacrolix/chansync v0.3.0 // indirect
	github.com/anacrolix/dht/v2 v2.20.0 // indirect
	github.com/anacrolix/envpprof v1.3.0 // indirect
	github.com/anacrolix/go-libutp v1.3.1 // indirect
	github.com/anacrolix/log v0.14.3-0.20230823030427-4b296d71a6b4 // indirect
	github.com/anacrolix/missinggo v1.3.0 // indirect
	github.com/anacrolix/missinggo/perf v1.0.0 // indirect
	github.com/anacrolix/missinggo/v2 v2.7.3 // indirect
	github.com/anacrolix/mmsg v1.0.0 // indirect
	github.com/anacrolix/multiless v0.3.1-0.20221221005021-2d12701f83f7 // indirect
	github.com/anacrolix/squirrel v0.6.0 // indirect
	github.com/anacrolix/stm v0.4.1-0.20221221005312-96d17df0e496 // indirect
	github.com/anacrolix/sync v0.5.1 // indirect
	github.com/anacrolix/torrent v1.53.1 // indirect
	github.com/anacrolix/upnp v0.1.3-0.20220123035249-922794e51c96 // indirect
	github.com/anacrolix/utp v0.1.0 // indirect
	github.com/andybalholm/brotli v1.0.6 // indirect
	github.com/andybalholm/cascadia v1.3.2 // indirect
	github.com/armon/go-radix v1.0.0 // indirect
	github.com/bahlo/generic-list-go v0.2.0 // indirect
	github.com/benbjohnson/immutable v0.4.1-0.20221220213129-8932b999621d // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/bits-and-blooms/bitset v1.3.0 // indirect
	github.com/blang/semver v3.5.1+incompatible // indirect
	github.com/bradfitz/iter v0.0.0-20191230175014-e8f45d346db8 // indirect
	github.com/cenkalti/backoff/v4 v4.2.1 // indirect
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dchest/siphash v1.2.3 // indirect
	github.com/dustin/go-humanize v1.0.1 // indirect
	github.com/dvyukov/go-fuzz v0.0.0-20231019021653-5581da83c52f // indirect
	github.com/edsrzf/mmap-go v1.1.0 // indirect
	github.com/enobufs/go-nats v0.0.1 // indirect
	github.com/felixge/httpsnoop v1.0.4 // indirect
	github.com/frankban/quicktest v1.14.6 // indirect
	github.com/gaukas/godicttls v0.0.4 // indirect
	github.com/getlantern/borda v0.0.0-20230421223744-4e208135f082 // indirect
	github.com/getlantern/broflake v0.0.0-20231108050304-13cef5126511 // indirect
	github.com/getlantern/bufconn v0.0.0-20210901195825-fd7c0267b493 // indirect
	github.com/getlantern/byteexec v0.0.0-20220903142956-e6ed20032cfd // indirect
	github.com/getlantern/cmux v0.0.0-20230301223233-dac79088a4c0 // indirect
	github.com/getlantern/cmux/v2 v2.0.0-20230301223233-dac79088a4c0 // indirect
	github.com/getlantern/cmuxprivate v0.0.0-20231025143958-503c5330c30b // indirect
	github.com/getlantern/common v1.2.1-0.20230427204521-6ac18c21db39 // indirect
	github.com/getlantern/context v0.0.0-20220418194847-3d5e7a086201 // indirect
	github.com/getlantern/detour v0.0.0-20230503144615-d3106a68f79e // indirect
	github.com/getlantern/dns v0.0.0-20210120185712-8d005533efa0 // indirect
	github.com/getlantern/dnsgrab v0.0.0-20230822102054-7ff232ec3148 // indirect
	github.com/getlantern/domains v0.0.0-20220311111720-94f59a903271 // indirect
	github.com/getlantern/elevate v0.0.0-20220903142053-479ab992b264 // indirect
	github.com/getlantern/ema v0.0.0-20190620044903-5943d28f40e4 // indirect
	github.com/getlantern/enhttp v0.0.0-20210901195634-6f89d45ee033 // indirect
	github.com/getlantern/enproxy v0.0.0-20180913191734-002212d417a4 // indirect
	github.com/getlantern/event v0.0.0-20210901195647-a7e3145142e6 // indirect
	github.com/getlantern/eventual/v2 v2.0.2 // indirect
	github.com/getlantern/fdcount v0.0.0-20210503151800-5decd65b3731 // indirect
	github.com/getlantern/fronted v0.0.0-20230601004823-7fec719639d8 // indirect
	github.com/getlantern/geolookup v0.0.0-20230327091034-aebe73c6eef4 // indirect
	github.com/getlantern/go-cache v0.0.0-20141028142048-88b53914f467 // indirect
	github.com/getlantern/go-socks5 v0.0.0-20171114193258-79d4dd3e2db5 // indirect
	github.com/getlantern/gowin v0.0.0-20160824205538-88fa116ddffc // indirect
	github.com/getlantern/hellosplitter v0.1.1 // indirect
	github.com/getlantern/hex v0.0.0-20220104173244-ad7e4b9194dc // indirect
	github.com/getlantern/hidden v0.0.0-20220104173330-f221c5a24770 // indirect
	github.com/getlantern/httpseverywhere v0.0.0-20201210200013-19ae11fc4eca // indirect
	github.com/getlantern/idletiming v0.0.0-20231030193830-6767b09f86db // indirect
	github.com/getlantern/iptool v0.0.0-20230112135223-c00e863b2696 // indirect
	github.com/getlantern/jibber_jabber v0.0.0-20210901195950-68955124cc42 // indirect
	github.com/getlantern/kcp-go/v5 v5.0.0-20220503142114-f0c1cd6e1b54 // indirect
	github.com/getlantern/kcpwrapper v0.0.0-20230327091313-c12d7c17c6de // indirect
	github.com/getlantern/keyman v0.0.0-20230503155501-4e864ca2175b // indirect
	github.com/getlantern/lampshade v0.0.0-20201109225444-b06082e15f3a // indirect
	github.com/getlantern/measured v0.0.0-20230919230611-3d9e3776a6cd // indirect
	github.com/getlantern/mitm v0.0.0-20231025115752-54d3e43899b7 // indirect
	github.com/getlantern/mockconn v0.0.0-20200818071412-cb30d065a848 // indirect
	github.com/getlantern/msgpack v3.1.4+incompatible // indirect
	github.com/getlantern/mtime v0.0.0-20200417132445-23682092d1f7 // indirect
	github.com/getlantern/multipath v0.0.0-20230510135141-717ed305ef50 // indirect
	github.com/getlantern/netx v0.0.0-20211206143627-7ccfeb739cbd // indirect
	github.com/getlantern/ops v0.0.0-20231025133620-f368ab734534 // indirect
	github.com/getlantern/osversion v0.0.0-20230401075644-c2a30e73c451 // indirect
	github.com/getlantern/preconn v1.0.0 // indirect
	github.com/getlantern/proxy/v3 v3.0.0-20231031142453-252ab678e6b7 // indirect
	github.com/getlantern/proxybench v0.0.0-20220404140110-f49055cb86de // indirect
	github.com/getlantern/psmux v1.5.15 // indirect
	github.com/getlantern/quicwrapper v0.0.0-20231108050956-d40f907fc227 // indirect
	github.com/getlantern/reconn v0.0.0-20161128113912-7053d017511c // indirect
	github.com/getlantern/rot13 v0.0.0-20220822172233-370767b2f782 // indirect
	github.com/getlantern/rotator v0.0.0-20160829164113-013d4f8e36a2 // indirect
	github.com/getlantern/shortcut v0.0.0-20211026183428-bf59a137fdec // indirect
	github.com/getlantern/tinywss v0.0.0-20211216020538-c10008a7d461 // indirect
	github.com/getlantern/tlsdialer/v3 v3.0.3 // indirect
	github.com/getlantern/tlsmasq v0.4.7-0.20230302000139-6e479a593298 // indirect
	github.com/getlantern/tlsresumption v0.0.0-20211216020551-6a3f901d86b9 // indirect
	github.com/getlantern/tlsutil v0.5.3 // indirect
	github.com/getlantern/trafficlog v1.0.1 // indirect
	github.com/getlantern/uuid v1.2.0 // indirect
	github.com/getlantern/winsvc v0.0.0-20160824205134-8bb3a5dbcc1d // indirect
	github.com/go-llsqlite/adapter v0.0.0-20230927005056-7f5ce7f0c916 // indirect
	github.com/go-llsqlite/crawshaw v0.4.0 // indirect
	github.com/go-logr/logr v1.3.0 // indirect
	github.com/go-logr/stdr v1.2.2 // indirect
	github.com/go-ole/go-ole v1.2.6 // indirect
	github.com/go-stack/stack v1.8.1 // indirect
	github.com/go-task/slim-sprig v0.0.0-20230315185526-52ccab3ef572 // indirect
	github.com/golang/gddo v0.0.0-20210115222349-20d68f94ee1f // indirect
	github.com/golang/protobuf v1.5.3 // indirect
	github.com/golang/snappy v0.0.4 // indirect
	github.com/google/btree v1.1.2 // indirect
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/google/gopacket v1.1.19 // indirect
	github.com/google/pprof v0.0.0-20231101202521-4ca4178f5c7a // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.18.1 // indirect
	github.com/hashicorp/golang-lru v1.0.2 // indirect
	github.com/huandu/xstrings v1.4.0 // indirect
	github.com/jaffee/commandeer v0.6.0 // indirect
	github.com/keighl/mandrill v0.0.0-20170605120353-1775dd4b3b41 // indirect
	github.com/klauspost/compress v1.17.2 // indirect
	github.com/klauspost/cpuid/v2 v2.2.6 // indirect
	github.com/klauspost/reedsolomon v1.11.8 // indirect
	github.com/kr/pretty v0.3.1 // indirect
	github.com/kr/text v0.2.0 // indirect
	github.com/libp2p/go-buffer-pool v0.1.0 // indirect
	github.com/mattn/go-isatty v0.0.17 // indirect
	github.com/matttproud/golang_protobuf_extensions/v2 v2.0.0 // indirect
	github.com/mitchellh/go-homedir v1.1.0 // indirect
	github.com/mitchellh/go-ps v1.0.0 // indirect
	github.com/mitchellh/go-server-timing v1.0.1 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/mschoch/smat v0.2.0 // indirect
	github.com/onsi/ginkgo/v2 v2.13.0 // indirect
	github.com/oxtoacart/bpool v0.0.0-20190530202638-03653db5a59c // indirect
	github.com/pborman/uuid v1.2.1 // indirect
	github.com/pion/datachannel v1.5.5 // indirect
	github.com/pion/dtls/v2 v2.2.7 // indirect
	github.com/pion/ice/v2 v2.3.11 // indirect
	github.com/pion/interceptor v0.1.25 // indirect
	github.com/pion/logging v0.2.2 // indirect
	github.com/pion/mdns v0.0.9 // indirect
	github.com/pion/randutil v0.1.0 // indirect
	github.com/pion/rtcp v1.2.10 // indirect
	github.com/pion/rtp v1.8.2 // indirect
	github.com/pion/sctp v1.8.9 // indirect
	github.com/pion/sdp/v3 v3.0.6 // indirect
	github.com/pion/srtp/v2 v2.0.17 // indirect
	github.com/pion/stun v0.6.1 // indirect
	github.com/pion/transport v0.14.1 // indirect
	github.com/pion/transport/v2 v2.2.4 // indirect
	github.com/pion/turn v1.4.0 // indirect
	github.com/pion/turn/v2 v2.1.4 // indirect
	github.com/pion/webrtc/v3 v3.2.21 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/prometheus/client_golang v1.17.0 // indirect
	github.com/prometheus/client_model v0.5.0 // indirect
	github.com/prometheus/common v0.45.0 // indirect
	github.com/prometheus/procfs v0.12.0 // indirect
	github.com/quic-go/qtls-go1-20 v0.4.1 // indirect
	github.com/quic-go/quic-go v0.40.0 // indirect
	github.com/refraction-networking/utls v1.3.3 // indirect
	github.com/remyoudompheng/bigfft v0.0.0-20230129092748-24d4a6f8daec // indirect
	github.com/rogpeppe/go-internal v1.10.0 // indirect
	github.com/rs/dnscache v0.0.0-20211102005908-e0241e321417 // indirect
	github.com/samber/lo v1.38.1 // indirect
	github.com/shadowsocks/go-shadowsocks2 v0.1.5 // indirect
	github.com/shirou/gopsutil v3.21.11+incompatible // indirect
	github.com/skratchdot/open-golang v0.0.0-20200116055534-eef842397966 // indirect
	github.com/templexxx/cpu v0.1.0 // indirect
	github.com/templexxx/xorsimd v0.4.2 // indirect
	github.com/tidwall/btree v1.6.0 // indirect
	github.com/tjfoc/gmsm v1.4.1 // indirect
	github.com/tklauser/go-sysconf v0.3.11 // indirect
	github.com/tklauser/numcpus v0.6.0 // indirect
	github.com/tkuchiki/go-timezone v0.2.2 // indirect
	github.com/xtaci/smux v1.5.24 // indirect
	github.com/yusufpapurcu/wmi v1.2.2 // indirect
	gitlab.com/yawning/edwards25519-extra.git v0.0.0-20211229043746-2f91fcc9fbdb // indirect
	gitlab.com/yawning/obfs4.git v0.0.0-20220904064028-336a71d6e4cf // indirect
	go.etcd.io/bbolt v1.3.6 // indirect
	go.opentelemetry.io/otel v1.19.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.19.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.19.0 // indirect
	go.opentelemetry.io/otel/metric v1.19.0 // indirect
	go.opentelemetry.io/otel/sdk v1.19.0 // indirect
	go.opentelemetry.io/otel/trace v1.19.0 // indirect
	go.opentelemetry.io/proto/otlp v1.0.0 // indirect
	go.uber.org/atomic v1.11.0 // indirect
	go.uber.org/mock v0.3.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	go.uber.org/zap v1.26.0 // indirect
	golang.org/x/crypto v0.14.0 // indirect
	golang.org/x/exp v0.0.0-20231006140011-7918f672742d // indirect
	golang.org/x/mod v0.14.0 // indirect
	golang.org/x/net v0.17.0 // indirect
	golang.org/x/sync v0.5.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	golang.org/x/time v0.3.0 // indirect
	golang.org/x/tools v0.14.0 // indirect
	google.golang.org/appengine v1.6.8 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20231106174013-bbf56f31fb17 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20231106174013-bbf56f31fb17 // indirect
	google.golang.org/grpc v1.59.0 // indirect
	google.golang.org/protobuf v1.31.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	howett.net/plist v1.0.0 // indirect
	modernc.org/libc v1.22.3 // indirect
	modernc.org/mathutil v1.5.0 // indirect
	modernc.org/memory v1.5.0 // indirect
	modernc.org/sqlite v1.21.1 // indirect
	nhooyr.io/websocket v1.8.10 // indirect
	zombiezen.com/go/sqlite v0.13.1 // indirect
)
