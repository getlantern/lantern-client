package internalsdk

import (
	"fmt"

	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// type Model interface {
// 	InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error)
// }
// BeginTransaction() error
// UseSchema(string) error
// SubscribeToPath(string) error
// UnsubscribeFromPath(string) error
// New Model that support multiple operation

type Model interface {
	InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error)
	Put(path string, value minisql.Values, fullText string) (bool, error)
	Delete(path string) (bool, error)
	Get(string) ([]byte, error)
}

type model struct {
	db  pathdb.DB
	txn pathdb.TX
}

func NewModel(schema string, mdb minisql.DB) (Model, error) {
	db, err := pathdb.NewDB(mdb, schema)
	if err != nil {
		return nil, err
	}
	return &model{
		db: db,
	}, nil
}

func (m *model) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "testDbConnection":

		log.Debugf("testDbConnection called")

		// Ensure at least one argument is provided for the path
		if arguments.Len() < 1 {
			return nil, fmt.Errorf("not enough arguments, expected at least 1")
		}
		log.Debugf("testDbConnection:getting argument ", arguments)
		pathArg := arguments.Get(0)
		if pathArg == nil {
			return nil, fmt.Errorf("testDbConnection path argument is nil")
		}

		log.Debugf("testDbConnection Path argument:get with ", pathArg)
		path := pathArg.String

		log.Debugf("testDbConnection Path argument: ", path)
		return nil, nil

	default:
		return nil, fmt.Errorf("unknown method: %s", method)
	}
}

func (m *model) Get(path string) ([]byte, error) {
	byte, err := m.db.Get(path)
	if err != nil {
		log.Errorf("Failed to get with path %v and error: %v", path, err)
		return nil, err
	}
	return byte, nil
}

// Internal method to start transaction do not need to expose this
func (m *model) startTransaction() error {
	if m.txn != nil {
		return log.Errorf("a transaction is already active")
	}
	var err error
	m.txn, err = m.db.Begin()
	return err
}

// Put value to specif path
// Todo try to find way to pass value directly
func (m *model) Put(path string, value minisql.Values, fullText string) (bool, error) {
	if m.txn == nil {
		if err := m.startTransaction(); err != nil {
			log.Errorf("Failed to start transaction: %v", err)
			return false, err
		}
	}
	arg := value.Get(0)
	err := m.txn.Put(path, arg.String(), nil, fullText, true)
	if err != nil {
		log.Errorf("Failed to put with path %v and value %v: %v", path, value, err)
		return false, err
	}

	log.Debugf("Put Added with path %v value:%v ", path, arg.String())
	return true, nil
}

func (m *model) Delete(path string) (bool, error) {
	if m.txn == nil {
		if err := m.startTransaction(); err != nil {
			return false, err
		}
	}
	err := m.txn.Delete(path)
	if err != nil {
		log.Errorf("Failed to Delete with path %v and value %v:", path, err)
		return false, err
	}
	return true, nil
}
