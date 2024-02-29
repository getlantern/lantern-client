package internalsdk

import (
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

const (
	pathVPNStatus = "/vpn_status"
	pathBandwidth = "/bandwidth"
)

// Custom Model implemnation
// VPNModel is a custom model derived from the baseModel.
type VPNModel struct {
	*baseModel
	manager VPNManager
}

type VPNManager interface {
	StartVPN()
	StopVPN()
}

func NewVPNModel(mdb minisql.DB) (*VPNModel, error) {
	base, err := newModel("vpn", mdb)
	if err != nil {
		return nil, err
	}
	model := &VPNModel{baseModel: base}
	model.baseModel.doInvokeMethod = model.doInvokeMethod
	base.db.RegisterType(5000, &protos.Bandwidth{})
	return model, model.initVpnModel()
}

func (s *VPNModel) SetManager(manager VPNManager) {
	s.manager = manager
}

func (s *VPNModel) doInvokeMethod(method string, arguments Arguments) (interface{}, error) {
	switch method {
	case "switchVPN":
		err := s.SwitchVPN(arguments.Get("on").Bool())
		if err != nil {
			return nil, err
		}
		return true, nil
	case "getVpnStatus":
		return s.GetVPNStatus()
	case "connectingDelay":
		on := arguments.Get("on").Bool()
		if on {
			s.SaveVPNStatus("connecting")
		} else {
			s.SaveVPNStatus("disconnecting")
		}
		return true, nil
	default:
		return s.methodNotImplemented(method)
	}
}

func (m *VPNModel) initVpnModel() error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		status, err := pathdb.Get[string](tx, pathVPNStatus)
		if err != nil {
			return errors.New("unable to read status: %v", err)
		}
		if status != "" {
			log.Debugf("Setting status to %v", status)
			return pathdb.Put(tx, pathVPNStatus, status, "")
		}
		log.Debug("Setting status to disconnected")
		return pathdb.Put(tx, pathVPNStatus, "disconnected", "")
	})
}

func (m *VPNModel) SwitchVPN(on bool) error {
	if on {
		log.Debug("Starting VPN")
		err := m.SaveVPNStatus("connecting")
		if err != nil {
			return err
		}
		m.manager.StartVPN()
	} else {
		log.Debug("Stopping VPN")
		err := m.SaveVPNStatus("disconnecting")
		if err != nil {
			return err
		}
		m.manager.StopVPN()
	}
	return nil
}

func (m *VPNModel) SaveVPNStatus(status string) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, pathVPNStatus, status, "")
	})
}

func (m *VPNModel) UpdateBandwidth(percent int64, remaining int64, allowedint int64, ttlSeconds int64) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		bandwidth := &protos.Bandwidth{
			Percent:    percent,
			Remaining:  remaining,
			Allowed:    allowedint,
			TtlSeconds: ttlSeconds,
		}
		return pathdb.Put(tx, pathBandwidth, bandwidth, "")
	})
}

func (m *VPNModel) GetVPNStatus() (string, error) {
	return pathdb.Get[string](m.db, pathVPNStatus)
}
