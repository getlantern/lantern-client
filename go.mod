module github.com/getlantern/lantern-client

go 1.23

toolchain go1.23.3

//replace github.com/getlantern/flashlight/v7 => ../flashlight

// replace github.com/getlantern/ipproxy => ../ipproxy
//replace github.com/getlantern/kindling => ../kindling

// replace github.com/getlantern/fronted => ../fronted

// replace github.com/getlantern/pathdb => ../pathDb/pathDb

replace github.com/elazarl/goproxy => github.com/getlantern/goproxy v0.0.0-20220805074304-4a43a9ed4ec6

replace github.com/lucas-clemente/quic-go => github.com/getlantern/quic-go v0.31.1-0.20230104154904-d810c964a217

replace github.com/keighl/mandrill => github.com/getlantern/mandrill v0.0.0-20221004112352-e7c04248adcb

replace github.com/google/netstack => github.com/getlantern/netstack v0.0.0-20220824143118-037ff0cd9c33

replace github.com/eycorsican/go-tun2socks => github.com/getlantern/go-tun2socks v1.16.12-0.20201218023150-b68f09e5ae93

replace github.com/tetratelabs/wazero => github.com/refraction-networking/wazero v1.7.1-w

require (
	github.com/1Password/srp v0.2.0
	github.com/blang/semver v3.5.1+incompatible
	github.com/dustin/go-humanize v1.0.1
	github.com/eycorsican/go-tun2socks v1.16.12-0.20201107203946-301549c435ff
	github.com/fsnotify/fsnotify v1.7.0
	github.com/getlantern/appdir v0.0.0-20200615192800-a0ef1968f4da
	github.com/getlantern/autoupdate v0.0.0-20240926204302-11d9aa2df948
	github.com/getlantern/common v1.2.1-0.20230427204521-6ac18c21db39
	github.com/getlantern/diagnostics v0.0.0-20230503185158-c2fc28ed22fe
	github.com/getlantern/dnsgrab v0.0.0-20240830183253-5c3e2386c39e
	github.com/getlantern/errors v1.0.5-0.20240410211607-f268a297d5d1
	github.com/getlantern/eventual v1.0.0
	github.com/getlantern/eventual/v2 v2.0.2
	github.com/getlantern/filepersist v0.0.0-20210901195658-ed29a1cb0b7c
	github.com/getlantern/flashlight/v7 v7.6.195
	github.com/getlantern/fronted v0.0.0-20250219040712-771dbc843542
	github.com/getlantern/geolookup v0.0.0-20230327091034-aebe73c6eef4
	github.com/getlantern/golog v0.0.0-20230503153817-8e72de7e0a65
	github.com/getlantern/hidden v0.0.0-20220104173330-f221c5a24770
	github.com/getlantern/i18n v0.0.0-20181205222232-2afc4f49bb1c
	github.com/getlantern/idletiming v0.0.0-20231030193830-6767b09f86db
	github.com/getlantern/ipproxy v0.0.0-20240923151842-ff95aca6e3dc
	github.com/getlantern/jibber_jabber v0.0.0-20210901195950-68955124cc42
	github.com/getlantern/launcher v0.0.0-20230622120034-fe87f9bff286
	github.com/getlantern/mtime v0.0.0-20200417132445-23682092d1f7
	github.com/getlantern/netx v0.0.0-20240830183145-c257516187f0
	github.com/getlantern/notifier v0.0.0-20240830181717-11f4c6c3fa95
	github.com/getlantern/ops v0.0.0-20231025133620-f368ab734534
	github.com/getlantern/osversion v0.0.0-20240418205916-2e84a4a4e175
	github.com/getlantern/pathdb v0.0.0-20231026090702-54ee1ddd99eb
	github.com/getlantern/profiling v0.0.0-20160317154340-2a15afbadcff
	github.com/getlantern/replica v0.15.0
	github.com/getlantern/safechannels v0.0.0-20201218194342-b4e5383e9627
	github.com/getlantern/sysproxy v0.0.0-20240711003440-384834c7b4cb
	github.com/getlantern/timezone v0.0.0-20210901200113-3f9de9d360c9
	github.com/getlantern/waitforserver v1.0.1
	github.com/getlantern/yaml v0.0.0-20190801163808-0c9bb1ebf426
	github.com/getsentry/sentry-go v0.31.1
	github.com/go-ping/ping v1.1.0
	github.com/go-resty/resty/v2 v2.16.3
	github.com/google/uuid v1.6.0
	github.com/gorilla/mux v1.8.1
	github.com/gorilla/websocket v1.5.3
	github.com/jackpal/gateway v1.0.13
	github.com/joho/godotenv v1.5.1
	github.com/leekchan/accounting v1.0.0
	github.com/moul/http2curl v1.0.0
	github.com/pterm/pterm v0.12.80
	github.com/shopspring/decimal v1.4.0
	github.com/stretchr/testify v1.10.0
	golang.org/x/crypto v0.32.0
	golang.org/x/mobile v0.0.0-20250106192035-c31d5b91ecc3
	golang.org/x/net v0.34.0
	golang.org/x/sys v0.29.0
	google.golang.org/protobuf v1.36.2
	nhooyr.io/websocket v1.8.17
)

require (
	atomicgo.dev/cursor v0.2.0 // indirect
	atomicgo.dev/keyboard v0.2.9 // indirect
	atomicgo.dev/schedule v0.1.0 // indirect
	github.com/Jigsaw-Code/outline-sdk/x v0.0.0-20250113162209-efa808309e1e // indirect
	github.com/alitto/pond/v2 v2.1.6 // indirect
	github.com/cloudflare/circl v1.5.0 // indirect
	github.com/coder/websocket v1.8.12 // indirect
	github.com/containerd/console v1.0.3 // indirect
	github.com/getlantern/kindling v0.0.0-20250219132519-d16b5c65a853 // indirect
	github.com/getlantern/lantern-water v0.0.0-20241218135103-60224336cf1d // indirect
	github.com/getlantern/sing-vmess v0.0.0-20241209111030-0f2c02b4eb9a // indirect
	github.com/goccy/go-yaml v1.15.13 // indirect
	github.com/gofrs/uuid/v5 v5.3.0 // indirect
	github.com/gookit/color v1.5.4 // indirect
	github.com/lithammer/fuzzysearch v1.1.8 // indirect
	github.com/mattn/go-runewidth v0.0.16 // indirect
	github.com/pion/dtls/v3 v3.0.3 // indirect
	github.com/pion/ice/v4 v4.0.2 // indirect
	github.com/pion/mdns/v2 v2.0.7 // indirect
	github.com/pion/srtp/v3 v3.0.4 // indirect
	github.com/pion/stun/v3 v3.0.0 // indirect
	github.com/pion/transport/v3 v3.0.7 // indirect
	github.com/pion/turn/v4 v4.0.0 // indirect
	github.com/pion/webrtc/v4 v4.0.0 // indirect
	github.com/protolambda/ctxlock v0.1.0 // indirect
	github.com/rivo/uniseg v0.4.4 // indirect
	github.com/sagernet/sing v0.6.0-beta.11 // indirect
	github.com/xo/terminfo v0.0.0-20220910002029-abceb7e1c41e // indirect
	go.opentelemetry.io/auto/sdk v1.1.0 // indirect
	golang.org/x/term v0.28.0 // indirect
)

require (
	filippo.io/edwards25519 v1.0.0 // indirect
	git.torproject.org/pluggable-transports/goptlib.git v1.2.0 // indirect
	github.com/Jigsaw-Code/outline-sdk v0.0.18-0.20241106233708-faffebb12629 // indirect
	github.com/Jigsaw-Code/outline-ss-server v1.5.0 // indirect
	github.com/OneOfOne/xxhash v1.2.8 // indirect
	github.com/OperatorFoundation/Replicant-go/Replicant/v3 v3.0.23 // indirect
	github.com/OperatorFoundation/Starbridge-go/Starbridge/v3 v3.0.17 // indirect
	github.com/OperatorFoundation/ghostwriter-go v1.0.6 // indirect
	github.com/OperatorFoundation/go-bloom v1.0.1 // indirect
	github.com/OperatorFoundation/go-shadowsocks2 v1.2.9 // indirect
	github.com/RoaringBitmap/roaring v1.9.4 // indirect
	github.com/Yawning/chacha20 v0.0.0-20170904085104-e3b1f968fc63 // indirect
	github.com/aead/ecdh v0.2.0 // indirect
	github.com/ajwerner/btree v0.0.0-20211221152037-f427b3e689c0 // indirect
	github.com/alecthomas/assert/v2 v2.3.0 // indirect
	github.com/alecthomas/atomic v0.1.0-alpha2 // indirect
	github.com/alextanhongpin/go-bandit v0.0.0-20191125130111-30de60d69bae // indirect
	github.com/anacrolix/chansync v0.6.0 // indirect
	github.com/anacrolix/confluence v1.16.0 // indirect
	github.com/anacrolix/dht/v2 v2.22.0 // indirect
	github.com/anacrolix/envpprof v1.4.0 // indirect
	github.com/anacrolix/generics v0.0.3-0.20240902042256-7fb2702ef0ca // indirect
	github.com/anacrolix/go-libutp v1.3.1 // indirect
	github.com/anacrolix/log v0.16.0 // indirect
	github.com/anacrolix/missinggo v1.3.0 // indirect
	github.com/anacrolix/missinggo/perf v1.0.0 // indirect
	github.com/anacrolix/missinggo/v2 v2.8.0 // indirect
	github.com/anacrolix/mmsg v1.0.0 // indirect
	github.com/anacrolix/multiless v0.4.0 // indirect
	github.com/anacrolix/squirrel v0.6.4 // indirect
	github.com/anacrolix/stm v0.5.0 // indirect
	github.com/anacrolix/sync v0.5.3 // indirect
	github.com/anacrolix/torrent v1.58.0 // indirect
	github.com/anacrolix/upnp v0.1.4 // indirect
	github.com/anacrolix/utp v0.2.0 // indirect
	github.com/andybalholm/brotli v1.1.1 // indirect
	github.com/armon/go-radix v1.0.0 // indirect
	github.com/bahlo/generic-list-go v0.2.0 // indirect
	github.com/benbjohnson/immutable v0.4.3 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/bits-and-blooms/bitset v1.20.0 // indirect
	github.com/blang/vfs v1.0.0 // indirect
	github.com/bradfitz/iter v0.0.0-20191230175014-e8f45d346db8 // indirect
	github.com/cenkalti/backoff/v4 v4.3.0
	github.com/cespare/xxhash v1.1.0 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/cockroachdb/apd v1.1.0 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dchest/siphash v1.2.3 // indirect
	github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f // indirect
	github.com/dsnet/compress v0.0.2-0.20210315054119-f66993602bf5 // indirect
	github.com/dsoprea/go-exif/v2 v2.0.0-20230826092837-6579e82b732d // indirect
	github.com/dsoprea/go-logging v0.0.0-20200710184922-b02d349568dd // indirect
	github.com/dsoprea/go-png-image-structure v0.0.0-20210512210324-29b889a6093d // indirect
	github.com/dsoprea/go-utility v0.0.0-20221003172846-a3e1774ef349 // indirect
	github.com/dvyukov/go-fuzz v0.0.0-20240924070022-e577bee5275c // indirect
	github.com/edsrzf/mmap-go v1.2.0 // indirect
	github.com/enobufs/go-nats v0.0.1 // indirect
	github.com/felixge/httpsnoop v1.0.4 // indirect
	github.com/frankban/quicktest v1.14.6 // indirect
	github.com/gaukas/wazerofs v0.1.0 // indirect
	github.com/getlantern/algeneva v0.0.0-20240605225338-caba0b3edf03 // indirect
	github.com/getlantern/broflake v0.0.0-20241220181831-2fc0e2904c90 // indirect
	github.com/getlantern/bufconn v0.0.0-20210901195825-fd7c0267b493 // indirect
	github.com/getlantern/byteexec v0.0.0-20220903142956-e6ed20032cfd // indirect
	github.com/getlantern/cmux v0.0.0-20230301223233-dac79088a4c0 // indirect
	github.com/getlantern/cmux/v2 v2.0.0-20230301223233-dac79088a4c0 // indirect
	github.com/getlantern/cmuxprivate v0.0.0-20231025143958-503c5330c30b // indirect
	github.com/getlantern/context v0.0.0-20220418194847-3d5e7a086201 // indirect
	github.com/getlantern/detour v0.0.0-20230503144615-d3106a68f79e // indirect
	github.com/getlantern/dns v0.0.0-20240124035051-0d45dd3cfe54 // indirect
	github.com/getlantern/domains v0.0.0-20220311111720-94f59a903271 // indirect
	github.com/getlantern/elevate v0.0.0-20220903142053-479ab992b264 // indirect
	github.com/getlantern/ema v0.0.0-20190620044903-5943d28f40e4 // indirect
	github.com/getlantern/enhttp v0.0.0-20210901195634-6f89d45ee033 // indirect
	github.com/getlantern/event v0.0.0-20210901195647-a7e3145142e6 // indirect
	github.com/getlantern/fdcount v0.0.0-20210503151800-5decd65b3731 // indirect
	github.com/getlantern/framed v0.0.0-20190601192238-ceb6431eeede // indirect
	github.com/getlantern/geo v0.0.0-20241129152027-2fc88c10f91e // indirect
	github.com/getlantern/go-socks5 v0.0.0-20171114193258-79d4dd3e2db5 // indirect
	github.com/getlantern/go-update v0.0.0-20230221120840-8d795213a8bc // indirect
	github.com/getlantern/gonat v0.0.0-20201001145726-634575ba87fb // indirect
	github.com/getlantern/gowin v0.0.0-20160824205538-88fa116ddffc // indirect
	github.com/getlantern/grtrack v0.0.0-20231025115619-bfbfadb228f3 // indirect
	github.com/getlantern/hellosplitter v0.1.1 // indirect
	github.com/getlantern/hex v0.0.0-20220104173244-ad7e4b9194dc // indirect
	github.com/getlantern/http-proxy-lantern/v2 v2.10.1 // indirect
	github.com/getlantern/httpseverywhere v0.0.0-20201210200013-19ae11fc4eca // indirect
	github.com/getlantern/iptool v0.0.0-20230112135223-c00e863b2696 // indirect
	github.com/getlantern/kcp-go/v5 v5.0.0-20220503142114-f0c1cd6e1b54 // indirect
	github.com/getlantern/kcpwrapper v0.0.0-20230327091313-c12d7c17c6de // indirect
	github.com/getlantern/keepcurrent v0.0.0-20240126172110-2e0264ca385d // indirect
	github.com/getlantern/keyman v0.0.0-20230503155501-4e864ca2175b // indirect
	github.com/getlantern/lampshade v0.0.0-20201109225444-b06082e15f3a // indirect
	github.com/getlantern/lantern-algeneva v0.0.0-20240930181006-6d3c00db1d5d // indirect
	github.com/getlantern/measured v0.0.0-20230919230611-3d9e3776a6cd // indirect
	github.com/getlantern/meta-scrubber v0.0.1 // indirect
	github.com/getlantern/multipath v0.0.0-20230510135141-717ed305ef50 // indirect
	github.com/getlantern/packetforward v0.0.0-20201001150407-c68a447b0360 // indirect
	github.com/getlantern/preconn v1.0.0 // indirect
	github.com/getlantern/proxy/v3 v3.0.0-20240328103708-9185589b6a99 // indirect
	github.com/getlantern/psmux v1.5.15 // indirect
	github.com/getlantern/quicwrapper v0.0.0-20240229232335-e6b4c3c30b2f // indirect
	github.com/getlantern/ratelimit v0.0.0-20220926192648-933ab81a6fc7 // indirect
	github.com/getlantern/rot13 v0.0.0-20220822172233-370767b2f782 // indirect
	github.com/getlantern/rotator v0.0.0-20160829164113-013d4f8e36a2 // indirect
	github.com/getlantern/shortcut v0.0.0-20211026183428-bf59a137fdec // indirect
	github.com/getlantern/telemetry v0.0.0-20230523155019-be7c1d8cd8cb // indirect
	github.com/getlantern/tinywss v0.0.0-20211216020538-c10008a7d461 // indirect
	github.com/getlantern/tlsdefaults v0.0.0-20171004213447-cf35cfd0b1b4 // indirect
	github.com/getlantern/tlsdialer/v3 v3.0.5 // indirect
	github.com/getlantern/tlsmasq v0.4.7-0.20230302000139-6e479a593298 // indirect
	github.com/getlantern/tlsresumption v0.0.0-20241210052744-a1c6aacc1d4d // indirect
	github.com/getlantern/tlsutil v0.5.3 // indirect
	github.com/getlantern/uuid v1.2.0 // indirect
	github.com/getlantern/winsvc v0.0.0-20160824205134-8bb3a5dbcc1d // indirect
	github.com/getlantern/withtimeout v0.0.0-20160829163843-511f017cd913 // indirect
	github.com/go-errors/errors v1.5.1 // indirect
	github.com/go-llsqlite/adapter v0.1.0 // indirect
	github.com/go-llsqlite/crawshaw v0.5.5 // indirect
	github.com/go-logr/logr v1.4.2 // indirect
	github.com/go-logr/stdr v1.2.2 // indirect
	github.com/go-redis/redis/v8 v8.11.5 // indirect
	github.com/go-stack/stack v1.8.1 // indirect
	github.com/go-task/slim-sprig/v3 v3.0.0 // indirect
	github.com/golang/gddo v0.0.0-20210115222349-20d68f94ee1f // indirect
	github.com/golang/geo v0.0.0-20230421003525-6adc56603217 // indirect
	github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da // indirect
	github.com/golang/snappy v0.0.4 // indirect
	github.com/google/btree v1.1.3 // indirect
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/google/pprof v0.0.0-20241210010833-40e02aabc2ad // indirect
	github.com/gopherjs/gopherjs v0.0.0-20200217142428-fce0ec30dd00 // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.25.1 // indirect
	github.com/hashicorp/golang-lru v1.0.2 // indirect
	github.com/huandu/xstrings v1.5.0 // indirect
	github.com/jaffee/commandeer v0.6.0 // indirect
	github.com/keighl/mandrill v0.0.0-20170605120353-1775dd4b3b41 // indirect
	github.com/kennygrant/sanitize v1.2.4 // indirect
	github.com/klauspost/compress v1.17.11 // indirect
	github.com/klauspost/cpuid/v2 v2.2.9 // indirect
	github.com/klauspost/pgzip v1.2.5 // indirect
	github.com/klauspost/reedsolomon v1.12.4 // indirect
	github.com/kr/binarydist v0.1.0 // indirect
	github.com/kr/pretty v0.3.1 // indirect
	github.com/kr/text v0.2.0 // indirect
	github.com/lib/pq v1.10.7 // indirect
	github.com/libp2p/go-buffer-pool v0.1.0 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/mattn/go-sqlite3 v2.0.2+incompatible // indirect
	github.com/mdlayher/netlink v1.1.0 // indirect
	github.com/mholt/archiver/v3 v3.5.1 // indirect
	github.com/miekg/dns v1.1.59 // indirect
	github.com/minio/sha256-simd v1.0.1 // indirect
	github.com/mitchellh/go-homedir v1.1.0 // indirect
	github.com/mitchellh/go-ps v1.0.0 // indirect
	github.com/mitchellh/go-server-timing v1.0.1 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/montanaflynn/stats v0.7.0 // indirect
	github.com/mr-tron/base58 v1.2.0 // indirect
	github.com/mschoch/smat v0.2.0 // indirect
	github.com/multiformats/go-multihash v0.2.3 // indirect
	github.com/multiformats/go-varint v0.0.7 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/ncruces/go-strftime v0.1.9 // indirect
	github.com/nwaples/rardecode v1.1.2 // indirect
	github.com/onsi/ginkgo/v2 v2.22.2 // indirect
	github.com/op/go-logging v0.0.0-20160315200505-970db520ece7 // indirect
	github.com/oschwald/geoip2-golang v1.9.0 // indirect
	github.com/oschwald/maxminddb-golang v1.12.0 // indirect
	github.com/oxtoacart/bpool v0.0.0-20190530202638-03653db5a59c // indirect
	github.com/pierrec/lz4/v4 v4.1.18 // indirect
	github.com/pion/datachannel v1.5.10 // indirect
	github.com/pion/dtls/v2 v2.2.12 // indirect
	github.com/pion/ice/v2 v2.3.37 // indirect
	github.com/pion/interceptor v0.1.37 // indirect
	github.com/pion/logging v0.2.2 // indirect
	github.com/pion/mdns v0.0.12 // indirect
	github.com/pion/randutil v0.1.0 // indirect
	github.com/pion/rtcp v1.2.15 // indirect
	github.com/pion/rtp v1.8.10 // indirect
	github.com/pion/sctp v1.8.35 // indirect
	github.com/pion/sdp/v3 v3.0.9 // indirect
	github.com/pion/srtp/v2 v2.0.20 // indirect
	github.com/pion/stun v0.6.1 // indirect
	github.com/pion/transport v0.14.1 // indirect
	github.com/pion/transport/v2 v2.2.10 // indirect
	github.com/pion/turn v1.4.0 // indirect
	github.com/pion/turn/v2 v2.1.6 // indirect
	github.com/pion/webrtc/v3 v3.3.5 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/prometheus/client_golang v1.20.5 // indirect
	github.com/prometheus/client_model v0.6.1 // indirect
	github.com/prometheus/common v0.61.0 // indirect
	github.com/prometheus/procfs v0.15.1 // indirect
	github.com/quic-go/quic-go v0.48.2 // indirect
	github.com/refraction-networking/utls v1.6.7 // indirect
	github.com/refraction-networking/water v0.7.0-alpha // indirect
	github.com/remyoudompheng/bigfft v0.0.0-20230129092748-24d4a6f8daec // indirect
	github.com/rogpeppe/go-internal v1.13.1 // indirect
	github.com/rs/dnscache v0.0.0-20230804202142-fc85eb664529 // indirect
	github.com/ryszard/goskiplist v0.0.0-20150312221310-2dfbae5fcf46 // indirect
	github.com/samber/lo v1.47.0 // indirect
	github.com/shadowsocks/go-shadowsocks2 v0.1.5 // indirect
	github.com/siddontang/go v0.0.0-20180604090527-bdc77568d726 // indirect
	github.com/skratchdot/open-golang v0.0.0-20200116055534-eef842397966 // indirect
	github.com/smartystreets/goconvey v1.7.2 // indirect
	github.com/songgao/water v0.0.0-20200317203138-2b4b6d7c09d8 // indirect
	github.com/spaolacci/murmur3 v1.1.0 // indirect
	github.com/stretchr/objx v0.5.2 // indirect
	github.com/tchap/go-patricia/v2 v2.3.1 // indirect
	github.com/templexxx/cpu v0.1.1 // indirect
	github.com/templexxx/xorsimd v0.4.3 // indirect
	github.com/tetratelabs/wazero v1.7.1 // indirect
	github.com/ti-mo/conntrack v0.3.0 // indirect
	github.com/ti-mo/netfilter v0.3.1 // indirect
	github.com/tidwall/btree v1.7.0 // indirect
	github.com/tjfoc/gmsm v1.4.1 // indirect
	github.com/tkuchiki/go-timezone v0.2.3 // indirect
	github.com/ulikunitz/xz v0.5.11 // indirect
	github.com/wlynxg/anet v0.0.5 // indirect
	github.com/xi2/xz v0.0.0-20171230120015-48954b6210f8 // indirect
	github.com/xtaci/smux v1.5.33 // indirect
	gitlab.com/yawning/edwards25519-extra.git v0.0.0-20211229043746-2f91fcc9fbdb // indirect
	gitlab.com/yawning/obfs4.git v0.0.0-20220204003609-77af0cba934d // indirect
	go.etcd.io/bbolt v1.3.11 // indirect
	go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.49.0 // indirect
	go.opentelemetry.io/otel v1.33.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlpmetric v0.42.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp v0.42.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.19.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.19.0 // indirect
	go.opentelemetry.io/otel/metric v1.33.0 // indirect
	go.opentelemetry.io/otel/sdk v1.33.0 // indirect
	go.opentelemetry.io/otel/sdk/metric v1.31.0 // indirect
	go.opentelemetry.io/otel/trace v1.33.0 // indirect
	go.opentelemetry.io/proto/otlp v1.5.0 // indirect
	go.uber.org/atomic v1.11.0 // indirect
	go.uber.org/mock v0.5.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	go.uber.org/zap v1.27.0 // indirect
	golang.org/x/exp v0.0.0-20250106191152-7588d65b2ba8 // indirect
	golang.org/x/mod v0.22.0 // indirect
	golang.org/x/sync v0.10.0 // indirect
	golang.org/x/text v0.21.0 // indirect
	golang.org/x/time v0.9.0 // indirect
	golang.org/x/tools v0.29.0 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20250106144421-5f5ef82da422 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250106144421-5f5ef82da422 // indirect
	google.golang.org/grpc v1.69.2 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	gvisor.dev/gvisor v0.0.0-20240912010154-1243db29d375 // indirect
	howett.net/plist v1.0.1 // indirect
	lukechampine.com/blake3 v1.3.0 // indirect
	modernc.org/libc v1.61.7 // indirect
	modernc.org/mathutil v1.7.1 // indirect
	modernc.org/memory v1.8.1 // indirect
	modernc.org/sqlite v1.34.4 // indirect
	zombiezen.com/go/sqlite v1.4.0 // indirect
)
