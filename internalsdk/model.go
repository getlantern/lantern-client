package internalsdk

import (
	"strings"

	"github.com/getlantern/errors"
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

type Arguments interface {
	Scalar() *minisql.Value
	Get(name string) *minisql.Value
}

// Model defines the methods that any model should implement
type Model interface {
	Name() string
	InvokeMethod(method string, arguments Arguments) (*minisql.Value, error)
	Subscribe(req *SubscriptionRequest) error
	Unsubscribe(id string)
}

// baseModel is a concrete implementation of the BaseModel interface.
type baseModel struct {
	name           string
	db             pathdb.DB
	doInvokeMethod func(method string, arguments Arguments) (interface{}, error)
}

// SubscriptionRequest defines the structure of a subscription request.
type SubscriptionRequest struct {
	ID             string
	PathPrefixes   string
	JoinDetails    bool
	ReceiveInitial bool
	Updater        UpdaterModel
}

// ChangeSet represents changes in a database.
type ChangeSet struct {
	cs *pathdb.ChangeSet[any]
}

type Update struct {
	Path  string
	Value *minisql.Value
}

func (cs *ChangeSet) HasUpdate() bool {
	return len(cs.cs.Updates) > 0
}

func (cs *ChangeSet) PopUpdate() (*Update, error) {
	for path, v := range cs.cs.Updates {
		delete(cs.cs.Updates, path)
		vb, err := v.Value.ValueOrProtoBytes()
		if err != nil {
			return nil, err
		}
		return &Update{Path: path, Value: minisql.NewValue(vb)}, nil
	}

	return nil, errors.New("no updates available")
}

func (cs *ChangeSet) HasDelete() bool {
	return len(cs.cs.Deletes) > 0
}

func (cs *ChangeSet) PopDelete() string {
	for path := range cs.cs.Deletes {
		delete(cs.cs.Deletes, path)
		return path
	}

	return ""
}

// UpdaterModel defines an interface to handle database changes.
type UpdaterModel interface {
	OnChanges(cs *ChangeSet) error
}

// NewModel initializes a new baseModel instance.
func newModel(name string, mdb minisql.DB) (*baseModel, error) {
	db, err := pathdb.NewDB(mdb, name)
	if err != nil {
		return nil, err
	}
	return &baseModel{
		name: name,
		db:   db,
	}, nil
}

func (m *baseModel) Name() string {
	return m.name
}

// InvokeMethod handles method invocations on the model.
func (m *baseModel) InvokeMethod(method string, arguments Arguments) (*minisql.Value, error) {
	result, err := m.doInvokeMethod(method, arguments)
	if err != nil {
		return nil, err
	}
	return minisql.NewValue(result), err
}

func (m *baseModel) methodNotImplemented(method string) (interface{}, error) {
	return nil, errors.New("method not implemented: %s", method)
}

// Subscribe subscribes to database changes based on the provided request.
func (m *baseModel) Subscribe(req *SubscriptionRequest) error {
	if req.Updater == nil {
		log.Error("UpdaterModel is nil in SubscriptionRequest")
		return errors.New("UpdaterModel cannot be nil")
	}
	pathPrefixesSlice := req.getPathPrefixes()
	log.Debugf("Subscribing with ID: %s, PathPrefixes: %v", req.ID, pathPrefixesSlice)

	sub := &pathdb.Subscription[interface{}]{
		ID:             req.ID,
		PathPrefixes:   pathPrefixesSlice,
		JoinDetails:    req.JoinDetails,
		ReceiveInitial: req.ReceiveInitial,
		OnUpdate: func(cs *pathdb.ChangeSet[interface{}]) error {
			return req.Updater.OnChanges(&ChangeSet{cs: cs})
		},
	}

	return pathdb.Subscribe(m.db, sub)
}

// Unsubscribe unsubscribes from database changes using the provided ID.
func (m *baseModel) Unsubscribe(path string) {
	pathdb.Unsubscribe(m.db, path)
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
