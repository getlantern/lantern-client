package internalsdk

import (
	"fmt"

	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

type Model interface {
	InvokeMethod(method string, arguments minisql.Values) (*Value, error)
}

type model struct {
	db pathdb.DB
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

func (m *model) InvokeMethod(method string, arguments minisql.Values) (*Value, error) {
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
