package internalsdk

import (
	"encoding/json"
	"fmt"
	"sync"
)

const (
	sessionModelChannelName = "SessionModel"
	eventModelChannelName   = "EventModel"
)

type FlutterMethodChannel struct {
	channelName string
	methods     map[string]func(string) (string, error)
}

func NewFlutterMethodChannel(channelName string, methods map[string]func(string) (string, error)) *FlutterMethodChannel {
	return &FlutterMethodChannel{
		channelName: channelName,
		methods:     methods,
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

func SessionModelChannel() *FlutterMethodChannel {
	return NewFlutterMethodChannel(sessionModelChannelName, map[string]func(string) (string, error){
		"SayHello":        sayHelloSessionModel,
		"SayHiMethodCall": sayHelloSessionModel,
	})
}

func EventModelChannel() *FlutterMethodChannel {
	return NewFlutterMethodChannel(eventModelChannelName, map[string]func(string) (string, error){
		"SayHello": sayHelloEventModel,
	})
}

func sayHelloSessionModel(argument string) (string, error) {
	// Here you should return your app name
	return "Hi, SessionModel", nil
}

func sayHelloEventModel(argument string) (string, error) {
	// Here you should return your app name
	return "Hi, EventModel", nil
}

/// Stream Handler

type streamHandler interface {
	OnListen(arguments string, events EventSink)
	OnCancel(arguments string)
}

type payload struct {
	Count        int64  `json:"count"`
	Details      bool   `json:"details"`
	Path         string `json:"path"`
	SubscriberID string `json:"subscriberID"`
}

type EventSink interface {
	Success(event string)
	Error(errorCode string, errorMessage string, errorDetails string)
}

type EventChannel struct {
	eventName     string
	handler       streamHandler
	activeSink    EventSink
	mu            sync.Mutex
	receiveStream ReceiveStream
}

type eventSinkImplementation struct {
	receiveStream ReceiveStream
}

func (esi *eventSinkImplementation) Success(event string) {
	esi.receiveStream.OnDataReceived(event)
}

func (esi *eventSinkImplementation) Error(errorCode string, errorMessage string, errorDetails string) {
	errorString := fmt.Sprintf("Error: code = %s, message = %s, details = %s", errorCode, errorMessage, errorDetails)
	esi.receiveStream.OnDataReceived(errorString)

}

type streamHandlerImplementation struct {
}

type ReceiveStream interface {
	OnDataReceived(data string)
}

func NewEventChannel(channelName string) *EventChannel {
	return &EventChannel{
		eventName: channelName,
		handler:   &streamHandlerImplementation{},
		activeSink: &eventSinkImplementation{
			receiveStream: nil,
		},
	}
}

func (s *streamHandlerImplementation) OnListen(arguments string, events EventSink) {
	var payloadMap payload
	err := json.Unmarshal([]byte(arguments), &payloadMap)
	if err != nil {
		// Handle error
		events.Error("PayloadParsingError", "Failed to parse payload", err.Error())
	}
	event := "Hi, " + payloadMap.Path

	// Send the event using the EventSink.
	events.Success(event)
}
func (s *streamHandlerImplementation) OnCancel(arguments string) {
	// Here you can implement the logic that should be executed when OnListen is called.
	// For example, you might want to start generating events here and send them using events.Success().
}

func (ec *EventChannel) SetReceiveStream(receiveStream ReceiveStream) {
	ec.receiveStream = receiveStream
	ec.activeSink.(*eventSinkImplementation).receiveStream = receiveStream
}

func (ec *EventChannel) InvokeOnListen(arguments string) {
	ec.mu.Lock()
	defer ec.mu.Unlock()

	ec.handler.OnListen(arguments, ec.activeSink)
}
