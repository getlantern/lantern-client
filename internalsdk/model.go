package internalsdk

import (
	"fmt"

	"github.com/getlantern/pathdb"
)

type Model interface {
	InvokeMethod(method string, arguments ValueArray) (*Value, error)
}

type model struct {
	db pathdb.DB
}

func NewModel(schema string, mdb DB) (Model, error) {
	db, err := pathdb.NewDB(&dbAdapter{mdb}, schema)
	if err != nil {
		return nil, err
	}

	return &model{
		db: db,
	}, nil
}

func (m *model) InvokeMethod(method string, arguments ValueArray) (*Value, error) {
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

		value, err := m.db.Get(path)
		if err != nil || value == nil {
			log.Debugf("testDbConnection DB Get error, value: ", err)
			// if error occurred or value is nil, return false
			return &Value{Type: TypeBool, Bool: false}, err
		}
		log.Debugf("testDbConnectionDB Get successful, value: ", value)
		// if everything is okay, return true
		return &Value{Type: TypeBool, Bool: true}, nil

	default:
		return nil, fmt.Errorf("unknown method: %s", method)
	}
}
