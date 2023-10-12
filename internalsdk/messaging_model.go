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

func NewMessagingModel(mdb minisql.DB) (*MessagingModel, error) {
	base, err := newModel("messaging", mdb)
	if err != nil {
		return nil, err
	}
	initMessagingModel(base)
	model := &MessagingModel{baseModel: base}
	return model, nil
}

func (s *MessagingModel) InvokeMethod(method string, arguments Arguments) (*minisql.Value, error) {
	switch method {
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

func initMessagingModel(m *baseModel) error {
	return pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		return pathdb.Put(tx, ONBOARDING_STATUS, false, "")
	})
}
