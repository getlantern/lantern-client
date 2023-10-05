package internalsdk

import (
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
	log.Debug("Creating VPN model")
	base, err := newModel("vpn", mdb)
	if err != nil {
		return nil, err
	}
	model := &VPNModel{baseModel: base}
	model.initVpnModel()
	return model, nil
}

func (s *VPNModel) SetManager(manager VPNManager) {
	s.manager = manager
}

func (s *VPNModel) InvokeMethod(method string, arguments Arguments) (*minisql.Value, error) {
	switch method {
	case "switchVPN":
		err := s.switchVPN(arguments.Get("on").Bool())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "saveVpnStatus":
		err := s.saveVPNStatus(arguments.Scalar().String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "getVpnStatus":
		byte, err := s.getVPNStatus()
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
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		rawStatus, err := tx.Get(PATH_VPN_STATUS)
		panicIfNecessary(err)
		status := string(rawStatus)
		if status != "" {
			pathdb.Put[string](tx, PATH_VPN_STATUS, status, "")
		} else {
			pathdb.Put[string](tx, PATH_VPN_STATUS, "disconnected", "")
		}
		return nil
	})
	return nil
}

func (m *VPNModel) switchVPN(on bool) error {
	if on {
		log.Debug("Starting VPN")
		err := m.saveVPNStatus("connecting")
		if err != nil {
			return err
		}
		m.manager.StartVPN()
	} else {
		log.Debug("Stopping VPN")
		err := m.saveVPNStatus("disconnecting")
		if err != nil {
			return err
		}
		m.manager.StopVPN()
	}
	return nil
}

func (m *VPNModel) saveVPNStatus(status string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, PATH_VPN_STATUS, status, "")
		return nil
	})
	return err
}

func (m *VPNModel) getVPNStatus() (string, error) {
	byte, err := m.db.Get(PATH_VPN_STATUS)
	panicIfNecessary(err)
	return string(byte), nil
}
