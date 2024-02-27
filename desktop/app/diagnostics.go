package app

import (
	"bytes"
	"compress/gzip"
	stderrors "errors"

	"github.com/getlantern/errors"
	"github.com/getlantern/yaml"

	"github.com/getlantern/lantern-client/desktop/diagnostics"
)

func (reporter *issueReporter) runDiagnostics() (reportYAML, gzippedPcapng []byte, err error) {
	defer func() {
		if r := recover(); r != nil {
			err = errors.New("recovered from panic while collecting diagnostics: %v", r)
		}
	}()

	errs := []error{}
	reportYAML, err = yaml.Marshal(diagnostics.Run(reporter.getProxies()))
	if err != nil {
		errs = append(errs, err)
	}
	gzippedPcapng, err = reporter.saveAndZipProxyTraffic()
	if err != nil && !stderrors.Is(err, errTrafficLogDisabled) {
		errs = append(errs, err)
	}
	return reportYAML, gzippedPcapng, combineErrors(errs...)
}

// Saves proxy traffic for captureSaveDuration and gzips the resulting pcapng.
func (reporter *issueReporter) saveAndZipProxyTraffic() ([]byte, error) {
	buf := new(bytes.Buffer)
	gzipW := gzip.NewWriter(buf)
	if err := reporter.getCapturedPackets(gzipW); err != nil {
		return nil, err
	}
	if err := gzipW.Close(); err != nil {
		return nil, errors.New("failed to close gzip writer: %v", err)
	}
	return buf.Bytes(), nil
}

func combineErrors(errs ...error) error {
	switch len(errs) {
	case 0:
		return nil
	case 1:
		return errs[0]
	default:
		return errors.New("multiple errors: %v", errs)
	}
}
