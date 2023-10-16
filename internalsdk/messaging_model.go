package internalsdk

import (
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Messing Model
type MessagingModel struct {
	*baseModel
}

func NewMessagingModel(mdb minisql.DB) (*MessagingModel, error) {
	base, err := newModel("messaging", mdb)
	if err != nil {
		return nil, err
	}
	err = initMessagingModel(base)
	if err != nil {
		return nil, err
	}
	model := &MessagingModel{baseModel: base}
	model.baseModel.doInvokeMethod = model.doInvokeMethod
	return model, nil
}

func (s *MessagingModel) doInvokeMethod(method string, arguments Arguments) (interface{}, error) {
	switch method {
	default:
		return s.methodNotImplemented(method)
	}
}

func initMessagingModel(m *baseModel) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, "onBoardingStatus", false, "")
	})
}
