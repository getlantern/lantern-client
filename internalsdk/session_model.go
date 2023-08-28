package internalsdk

import (
	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// Custom Model implemnation
// SessionModel is a custom model derived from the baseModel.
type SessionModel struct {
	*baseModel
}

// List of const we are using for Session Model
// Might be eaier to move all const at one place
const DEVICE_ID = "deviceid"
const PAYMENT_TEST_MODE = "paymentTestMode"
const USER_ID = "userid"
const PATH_PRO_USER = "prouser"
const PATH_SDK_VERSION = "sdkVersion"
const PATH_USER_LEVEL = "userLevel"
const CHAT_ENABLED = "chatEnabled"
const DEVELOPMNET_MODE = "developmentMode"

// NewSessionModel initializes a new SessionModel instance.
func NewSessionModel(schema string, mdb minisql.DB) (*SessionModel, error) {
	base, err := newModel(schema, mdb)
	if err != nil {
		return nil, err
	}
	model := &SessionModel{base.(*baseModel)}
	return model, nil
}

func (s *SessionModel) InvokeMethod(method string, arguments minisql.Values) (*minisql.Value, error) {
	switch method {
	case "initSesssionModel":
		initSessionModel(s.baseModel)
		return minisql.NewValueBool(true), nil
	default:
		return s.baseModel.InvokeMethod(method, arguments)
	}
}

// InvokeMethod handles method invocations on the SessionModel.
func initSessionModel(m *baseModel) {

	// Init few path for startup
	pathdb.Mutate(m.db, func(tx pathdb.TX) error {
		pathdb.Put[bool](tx, PATH_PRO_USER, false, "")
		pathdb.Put[bool](tx, CHAT_ENABLED, false, "")

		pathdb.Put[string](tx, PATH_SDK_VERSION, SDKVersion(), "")

		// userLevel, error := tx.Get(PATH_USER_LEVEL)
		// if error != nil {
		// 	return fmt.Errorf("Error while retriving %v and error %v", PATH_USER_LEVEL, error)
		// }
		// pathdb.Put[[]byte](tx, PATH_USER_LEVEL, userLevel, "")

		//For now lets just use static
		pathdb.Put[bool](tx, DEVELOPMNET_MODE, true, "")
		pathdb.Put[bool](tx, "hasSucceedingProxy", true, "")
		return nil
	})
}

// This method checks that session Model is implementing all methods or not
func ensureImplements() {
	_, ok := interface{}(SessionModel{}).(Session)
	if !ok {
		panic("SessionModel does not implement Session interface")
	}
}

func (s *SessionModel) GetAppName() string {
	return "Lantern-IOS"
}

func (s *SessionModel) GetDeviceID() string {
	byte, err := s.baseModel.db.Get(DEVICE_ID)
	if err != nil {
		panicIfNecessary(err)
	}
	//Todo Find better way to deserialize the values
	// Also fine generic way
	return string(byte)
}

func (s *SessionModel) GetUserID() string {
	paymentTestMode, err := s.baseModel.db.Get(PAYMENT_TEST_MODE)
	panicIfNecessary(err)
	//Todo find way to deserialize the values
	paymentTestModeStr := string(paymentTestMode)
	if paymentTestModeStr == "true" {
		// When we're testing payments, use a specific test user ID. This is a user in our
		// production environment but that gets special treatment from the proserver to hit
		// payment providers' test endpoints.
		return "9007199254740992L"
	} else {
		userId, err := s.baseModel.db.Get(USER_ID)
		panicIfNecessary(err)
		return string(userId)
	}

}
