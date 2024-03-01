package ios

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"net"

	"github.com/getlantern/errors"
)

var (
	networkByteOrder = binary.BigEndian

	noIpPacket = ipPacket{}
)

func parseIPPacket(raw []byte) (ipPacket, error) {
	ipVersion := uint8(raw[0]) >> 4
	if ipVersion != 4 {
		return noIpPacket, errors.New("Unsupported ip protocol version: %v", ipVersion)
	}

	pkt := ipPacket{raw: raw, ipVersion: ipVersion}
	return pkt.parseV4()
}

type ipPacket struct {
	raw       []byte
	ipVersion uint8
	ipProto   uint8
	srcAddr   *net.IPAddr
	dstAddr   *net.IPAddr
	payload   []byte
}

func (pkt ipPacket) String() string {
	b, err := json.Marshal(&pkt)
	if err != nil {
		return ""
	}
	return string(b)
}

func (pkt ipPacket) parseV4() (ipPacket, error) {
	ihl := uint8(pkt.raw[0]) & 0x0F
	length := networkByteOrder.Uint16(pkt.raw[2:4])
	if length < 20 {
		return pkt, errors.New("Invalid (too small) IP length (%d < 20)", length)
	} else if ihl < 5 {
		return pkt, errors.New("Invalid (too small) IP header length (%d < 5)", ihl)
	} else if int(ihl*4) > int(length) {
		return pkt, errors.New("Invalid IP header length > IP length (%d > %d)", ihl, length)
	} else if int(ihl)*4 > len(pkt.raw) {
		return pkt, errors.New("Not all IP header bytes available")
	}

	pkt.ipProto = uint8(pkt.raw[9])
	pkt.srcAddr = &net.IPAddr{IP: net.IP(pkt.raw[12:16])}
	pkt.dstAddr = &net.IPAddr{IP: net.IP(pkt.raw[16:20])}
	pkt.payload = pkt.raw[ihl*4:]

	return pkt, nil
}

func (pkt ipPacket) ft() fourtuple {
	return fourtuple{
		src: addr{ip: pkt.srcAddr.String(), port: networkByteOrder.Uint16(pkt.payload[0:2])},
		dst: addr{ip: pkt.dstAddr.String(), port: networkByteOrder.Uint16(pkt.payload[2:4])},
	}
}

type addr struct {
	ip   string
	port uint16
}

func (a addr) String() string {
	return fmt.Sprintf("%v:%d", a.ip, a.port)
}

type fourtuple struct {
	src addr
	dst addr
}

func (ft fourtuple) String() string {
	return fmt.Sprintf("%v -> %v", ft.src, ft.dst)
}
