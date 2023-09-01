package internalsdk

import (
	"encoding/base64"
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
	Value      *MyValue
}

// UpdaterModel defines an interface to handle database changes.
type UpdaterModel interface {
	OnChanges(cs *ChangeSetInterface) error
}
type MyValue struct {
	minisql.Value
}

// Custom JSON serialization method for Value type
func (v *MyValue) MarshalJSON() ([]byte, error) {

	switch v.Type {
	case minisql.ValueTypeBytes:
		return json.Marshal(map[string]interface{}{
			"Type":  v.Type,
			"Value": base64.StdEncoding.EncodeToString(v.Bytes()),
		})
	case minisql.ValueTypeString:
		return json.Marshal(map[string]interface{}{
			"Type":  v.Type,
			"Value": v.String(),
		})
	case minisql.ValueTypeInt:
		return json.Marshal(map[string]interface{}{
			"Type":  v.Type,
			"Value": v.Int(),
		})
	case minisql.ValueTypeBool:
		return json.Marshal(map[string]interface{}{
			"Type":  v.Type,
			"Value": v.Bool(),
		})
	default:
		return nil, fmt.Errorf("unsupported value type: %d", v.Type)
	}
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
	pathPrefixesSlice := req.getPathPrefixes()
	sub := &pathdb.Subscription[interface{}]{
		ID:             req.ID,
		PathPrefixes:   pathPrefixesSlice,
		JoinDetails:    req.JoinDetails,
		ReceiveInitial: req.ReceiveInitial,
		OnUpdate: func(cs *pathdb.ChangeSet[interface{}]) error {
			updatesMap := make(map[string]*ItemInterface)
			for k, itemWithRaw := range cs.Updates {
				rawValue, err := itemWithRaw.Value.Value()
				if err != nil {
					log.Debugf("Error extracting raw value:", err)
					return err
				}
				// When serlizeing might get other other type
				//make sure to convered to only supported types
				convertedValue := convertValueToSupportedTypes(rawValue)
				val := minisql.NewValue(convertedValue)
				// Need wrap to coz we need to send to json
				myVal := &MyValue{Value: *val}
				log.Debugf("my val type %v", val.Type)
				updatesMap[k] = &ItemInterface{
					Path:       itemWithRaw.Path,
					DetailPath: itemWithRaw.DetailPath,
					Value:      myVal,
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
			// log.Debugf("Serialized updates:", string(updatesSerialized))
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
