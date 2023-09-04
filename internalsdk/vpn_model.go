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
