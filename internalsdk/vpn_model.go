package internalsdk

import (
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// VPNModel is a custom model derived from the baseModel.
type VpnModel struct {
	*baseModel
}

const PATH_VPN_STATUS = "/vpn_status"
const PATH_SERVER_INFO = "/server_info"
const PATH_BANDWIDTH = "/bandwidth"

// NewSessionModel initializes a new SessionModel instance.
func NewVpnModel(schema string, mdb minisql.DB) (*VpnModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	initVpnModel(base.(*baseModel))
	model := &VpnModel{base.(*baseModel)}
	return model, nil
}

func (s *VpnModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "switchVPN":
		jsonString := arguments.Get(0)
		err := switchVPN(s.baseModel, jsonString.Bool())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "saveVpnStatus":
		jsonString := arguments.Get(0)
		err := saveVPNStatus(s.baseModel, jsonString.String())
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueBool(true), nil
		}
	case "getVpnStatus":
		byte, err := getVPNStatus(s.baseModel)
		if err != nil {
			return nil, err
		} else {
			return minisql.NewValueString(byte), nil
		}
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

func initVpnModel(m *baseModel) error {
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

func switchVPN(m *baseModel, status bool) error {
	return nil
}

func saveVPNStatus(m *baseModel, status string) error {
	err := pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[string](tx, PATH_VPN_STATUS, status, "")
		return nil
	})
	return err
}

func getVPNStatus(m *baseModel) (string, error) {
	byte, err := m.db.Get(PATH_VPN_STATUS)
	panicIfNecessary(err)
	return string(byte), nil
}
