/*
	package doh implements dns-over-https

Example:

	ctx, cancelFunc := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancelFunc()
	httpClient := &http.Client{Timeout: time.Second * 10}
	resp, err := MakeDohRequest(ctx, httpClient, doh.DnsDomain("cloudflare.com), doh.TypeA)
	require.NoError(t, err)
	require.NotNil(t, resp)
*/
package doh

import (
	"bytes"
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/getlantern/golog"
	"golang.org/x/net/idna"
)

type DnsDomain string
type DnsType string

var (
	TypeA     = DnsType("A")
	TypeAAAA  = DnsType("AAAA")
	TypeCNAME = DnsType("CNAME")
	TypeMX    = DnsType("MX")
	TypeTXT   = DnsType("TXT")
	TypeSPF   = DnsType("SPF")
	TypeNS    = DnsType("NS")
	TypeSOA   = DnsType("SOA")
	TypePTR   = DnsType("PTR")
	TypeANY   = DnsType("ANY")

	log = golog.LoggerFor("doh")
)

type DnsQuestion struct {
	Name string `json:"name"`
	Type int    `json:"type"`
}

type DnsAnswer struct {
	Name string `json:"name"`
	Type int    `json:"type"`
	TTL  int    `json:"TTL"`
	Data string `json:"data"`
}

type DnsResponse struct {
	Status   int           `json:"Status"`
	TC       bool          `json:"TC"`
	RD       bool          `json:"RD"`
	RA       bool          `json:"RA"`
	AD       bool          `json:"AD"`
	CD       bool          `json:"CD"`
	Question []DnsQuestion `json:"Question"`
	Answer   []DnsAnswer   `json:"Answer"`
	Provider string        `json:"provider"`
}

func MakeDohRequest(ctx context.Context,
	httpClient *http.Client,
	domain DnsDomain,
	typ DnsType) (*DnsResponse, error) {

	name, err := idna.New(
		idna.MapForLookup(),
		idna.Transitional(true),
		idna.StrictDomainName(false),
	).ToASCII(strings.TrimSpace(string(domain)))
	if err != nil {
		return nil, log.Errorf("getting idna for domain [%v]: %v", domain, err)
	}

	req, err := http.NewRequest("GET", "https://cloudflare-dns.com/dns-query", nil)
	if err != nil {
		return nil, log.Errorf("building doh request to cloudflare %v", err)
	}
	req = req.WithContext(ctx)
	req.Header.Set("accept", "application/dns-json")
	q := req.URL.Query()
	q.Add("name", name)
	q.Add("type", strings.TrimSpace(string(typ)))
	req.URL.RawQuery = q.Encode()
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, log.Errorf("sending doh request to cloudflare %v", err)
	}

	defer resp.Body.Close()
	bodyBuf, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, log.Errorf("read doh response body %v", err)
	}

	rr := &DnsResponse{
		Provider: "cloudflare",
	}
	err = json.NewDecoder(bytes.NewBuffer(bodyBuf)).Decode(rr)
	if err != nil {
		return nil, log.Errorf("decoding doh response body as json %v", err)
	}
	if rr.Status != 0 {
		return rr, log.Errorf("cloudflare failed response code %d", rr.Status)
	}

	return rr, nil
}
