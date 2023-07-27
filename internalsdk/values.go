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

func newValueArray(values []interface{}) ValueArray {
	va := make(valueArray, len(values))
	for i, val := range values {
		va.Set(i, newValue(val))
	}
	return va
}

func (va valueArray) Len() int {
	return len(va)
}

func (va valueArray) Get(index int) *Value {
	return newValue(va[index])
}

func (va valueArray) Set(index int, value *Value) {
	va[index] = value.asInterface()
}
