package internalsdk

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// BaseModel defines the methods that any model should implement
type BaseModel interface {
	InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error)
	Subscribe(req *SubscriptionRequest) error
	Unsubscribe(id string) error
}

// baseModel is a concrete implementation of the BaseModel interface.
type baseModel struct {
	db pathdb.DB
}

// SubscriptionRequest defines the structure of a subscription request.
type SubscriptionRequest struct {
	ID             string
	PathPrefixes   string
	JoinDetails    bool
	ReceiveInitial bool
	Updater        UpdaterModel
}

// ChangeSetInterface represents changes in a database.
type ChangeSetInterface struct {
	UpdatesSerialized string
	DeletesSerialized string
}

// ItemInterface represents an item in the database with its associated values.
type ItemInterface struct {
	Path       string
	DetailPath string
	Value      *minisql.Value
}

// UpdaterModel defines an interface to handle database changes.
type UpdaterModel interface {
	OnChanges(cs *ChangeSetInterface) error
}

// NewModel initializes a new baseModel instance.
func newModel(schema string, mdb minisql.DB) (BaseModel, error) {
	db, err := pathdb.NewDB(mdb, schema)
	if err != nil {
		return nil, err
	}
	return &baseModel{
		db: db,
	}, nil
}

// InvokeMethod handles method invocations on the model.
func (m *baseModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	return nil, fmt.Errorf("method not implemented: %s", method)
}

// Subscribe subscribes to database changes based on the provided request.
func (m *baseModel) Subscribe(req *SubscriptionRequest) error {
	log.Debugf("Subscribe called with request:", req)
	pathPrefixesSlice := req.getPathPrefixes()
	log.Debugf("Path Prefixes:", pathPrefixesSlice[0])

	sub := &pathdb.Subscription[interface{}]{
		ID:             req.ID,
		PathPrefixes:   pathPrefixesSlice,
		JoinDetails:    req.JoinDetails,
		ReceiveInitial: req.ReceiveInitial,
		OnUpdate: func(cs *pathdb.ChangeSet[interface{}]) error {
			log.Debugf("OnUpdate called with ChangeSet:", cs)

			updatesMap := make(map[string]*ItemInterface)
			for k, itemWithRaw := range cs.Updates {
				rawValue, err := itemWithRaw.Value.Value()
				if err != nil {
					log.Debugf("Error extracting raw value:", err)
					return err
				}
				val := minisql.NewValue(rawValue)

				updatesMap[k] = &ItemInterface{
					Path:       itemWithRaw.Path,
					DetailPath: itemWithRaw.DetailPath,
					Value:      val,
				}
			}

			// Serialize updates and deletes to JSON
			updatesSerialized, err := json.Marshal(updatesMap)
			if err != nil {
				log.Debugf("Error serializing updates:", err)
				return err
			}

			deletesSerialized, err := json.Marshal(cs.Deletes)
			if err != nil {
				log.Debugf("Error serializing deletes:", err)

				return err
			}
			log.Debugf("Serialized updates:", string(updatesSerialized))
			log.Debugf("Serialized deletes:", string(deletesSerialized))

			csInterface := &ChangeSetInterface{
				UpdatesSerialized: string(updatesSerialized),
				DeletesSerialized: string(deletesSerialized),
			}

			return req.Updater.OnChanges(csInterface)
		},
	}

	return pathdb.Subscribe(m.db, sub)
}

// Unsubscribe unsubscribes from database changes using the provided ID.
func (m *baseModel) Unsubscribe(path string) error {
	pathdb.Unsubscribe(m.db, path)
	return nil
}

func (s *SubscriptionRequest) getPathPrefixes() []string {
	// Split the PathPrefixes string by comma
	parts := strings.Split(s.PathPrefixes, ",")

	// Iterate over each part and trim the trailing '%'
	for i, part := range parts {
		parts[i] = strings.TrimSuffix(part, "%")
	}

	return parts
}

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	BaseModel
}

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(schema string, mdb minisql.DB) (*SessionModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	// Initialization for SessionModel
	initSessionModel(base.(*baseModel))
	return &SessionModel{base}, nil
}

func (s *SessionModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "Hello":
		return minisql.NewValueString("Hello"), nil
	default:
		return s.BaseModel.InvokeMethod(method, arguments)
	}
}

// InvokeMethod handles method invocations on the SessionModel.
func initSessionModel(m *baseModel) {
	const PATH_PRO_USER = "prouser"
	const PATH_SDK_VERSION = "sdkVersion"
	const PATH_USER_LEVEL = "userLevel"
	const CHAT_ENABLED = "chatEnabled"
	const DEVELOPMNET_MODE = "developmentMode"

	// Init few path for startup
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, PATH_PRO_USER, false, "")
		pathdb.Put[bool](tx, CHAT_ENABLED, false, "")
		pathdb.Put[bool](tx, DEVELOPMNET_MODE, true, "")
		pathdb.Put[string](tx, PATH_SDK_VERSION, SDKVersion(), "")

		// userLevel, error := tx.Get(PATH_USER_LEVEL)
		// if error != nil {
		// 	return fmt.Errorf("Error while retriving %v and error %v", PATH_USER_LEVEL, error)
		// }
		// pathdb.Put[[]byte](tx, PATH_USER_LEVEL, userLevel, "")
		return nil
	})
}

// Messing Model
type MessagingModel struct {
	BaseModel
}

func NewMessagingModel(schema string, mdb minisql.DB) (*MessagingModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	// Initialization for SessionModel
	initSessionModel(base.(*baseModel))
	return &MessagingModel{base}, nil
}

func (s *MessagingModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "Hello":
		return minisql.NewValueString("Hello"), nil
	default:
		return s.BaseModel.InvokeMethod(method, arguments)
	}
}
