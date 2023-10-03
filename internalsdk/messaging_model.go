package internalsdk

import (
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Messing Model
type MessagingModel struct {
	*baseModel
}

const ONBOARDING_STATUS = "onBoardingStatus"

func NewMessagingModel(schema string, mdb minisql.DB) (*MessagingModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	// Initialization for Messaging
	initMessagingModel(base.(*baseModel))
	model := &MessagingModel{base.(*baseModel)}
	return model, nil
}

func (s *MessagingModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "Hello":
		return minisql.NewValueString("Hello"), nil
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

func initMessagingModel(m *baseModel) error {
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, ONBOARDING_STATUS, false, "")
		return nil
	})
	return nil
}
