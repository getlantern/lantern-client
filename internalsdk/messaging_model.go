package internalsdk

import "github.com/getlantern/pathdb/minisql"

// Messing Model
type MessagingModel struct {
	*baseModel
}

func NewMessagingModel(schema string, mdb minisql.DB) (*MessagingModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	// Initialization for SessionModel
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
