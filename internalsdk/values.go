package internalsdk

const (
	TypeString = 0
	TypeInt    = 1
	TypeBool   = 2
)

type Value struct {
	Type   int
	String string
	Int    int
	Bool   bool
}

func newValue(val interface{}) *Value {
	switch t := val.(type) {
	case string:
		return &Value{Type: TypeString, String: t}
	case int:
		return &Value{Type: TypeInt, Int: t}
	case bool:
		return &Value{Type: TypeBool, Bool: t}
	default:
		return nil
	}
}

func (v *Value) asInterface() interface{} {
	if v == nil {
		return nil
	}

	switch v.Type {
	case TypeString:
		return v.String
	case TypeInt:
		return v.Int
	case TypeBool:
		return v.Bool
	default:
		return nil
	}
}

type ValueArray interface {
	Len() int
	Get(index int) *Value
	Set(index int, value *Value)
}

type valueArray []interface{}

type valueArrayWrapper struct {
	values valueArray
}

func (vaw *valueArrayWrapper) Len() int {
	return len(vaw.values)
}

func (vaw *valueArrayWrapper) Get(index int) *Value {
	return newValue(vaw.values[index])
}

func (vaw *valueArrayWrapper) Set(index int, value *Value) {
	vaw.values[index] = value.asInterface()
}

func newValueArray(values []interface{}) *valueArrayWrapper {
	va := make(valueArray, len(values))
	for i, val := range values {
		va[i] = newValue(val).asInterface()
	}
	return &valueArrayWrapper{values: va}
}
