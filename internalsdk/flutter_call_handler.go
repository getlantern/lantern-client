package internalsdk

import "fmt"

type FlutterMethodChannel struct {
	methods map[string]func(string) (string, error)
}

func SetupFlutterChannel() *FlutterMethodChannel {
	return &FlutterMethodChannel{
		methods: map[string]func(string) (string, error){
			"SayHello": sayHello,
		},
	}
}

func (m *FlutterMethodChannel) InvokeMethod(name string, argument string) (string, error) {
	if handler, exists := m.methods[name]; exists {
		result, err := handler(argument)
		if err != nil {
			return "", fmt.Errorf("error in method %q: %w", name, err)
		}
		return result, nil
	}
	return "", fmt.Errorf("method %q not implemented", name)
}

func sayHello(argument string) (string, error) {
	// Here you should return your app name
	return argument, nil
}
