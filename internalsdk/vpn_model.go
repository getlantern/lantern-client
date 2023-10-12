package internalsdk

import (
	"github.com/getlantern/errors"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

const PATH_VPN_STATUS = "/vpn_status"
const PATH_BANDWIDTH = "/bandwidth"

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
	return model, model.initVpnModel()
}

func (s *VPNModel) SetManager(manager VPNManager) {
	s.manager = manager
}

func (s *VPNModel) InvokeMethod(method string, arguments Arguments) (*minisql.Value, error) {
	switch method {
	case "switchVPN":
		err := s.SwitchVPN(arguments.Get("on").Bool())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "getVpnStatus":
		byte, err := s.GetVPNStatus()
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueString(byte), nil
		}
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

func (m *VPNModel) initVpnModel() error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		status, err := pathdb.Get[string](tx, PATH_VPN_STATUS)
		if err != nil {
			return errors.New("unable to read status: %v", err)
		}
		if status != "" {
			log.Debugf("Setting status to %v", status)
			return pathdb.Put(tx, PATH_VPN_STATUS, status, "")
		}
		log.Debug("Setting status to disconnected")
		return pathdb.Put(tx, PATH_VPN_STATUS, "disconnected", "")
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
		return pathdb.Put(tx, PATH_VPN_STATUS, status, "")
	})
}

func (m *VPNModel) GetVPNStatus() (string, error) {
	byte, err := m.db.Get(PATH_VPN_STATUS)
	panicIfNecessary(err)
	return string(byte), nil
}
