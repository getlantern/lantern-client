package internalsdk

import (
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
		"SayHello": sayHelloSessionModel,
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
	// Here you can implement what should happen when an error occurs.
	// For example, you might want to log the error or send it to your receiveStream function.
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
	// Here you can implement the logic that should be executed when OnListen is called.
	// For example, you might want to start generating events here and send them using events.Success().
	// Generate a "Hi" event with the given argument.
	event := "Hi, " + arguments

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
