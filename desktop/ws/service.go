package ws

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
)

type helloFnType func(func(interface{}))

type newMsgFnType func() interface{}

// UIChannel is a WebSocket server which can be attached to an HTTP server.
// Services can be registered with specific types so once the WebSocket
// clients are connected, they can exchange any JSON messages with the services.
type UIChannel interface {
	// Handler exposes the UIChannel as an http.Handler
	Handler() http.Handler
	// Register registers a service with an optional helloFn to send initial
	// message to connected clients.
	Register(t string, helloFn helloFnType) (*Service, error)
	// SendMessage sends data over the given websocket channel
	SendMessage(ch string, data any) error
	// RegisterWithMsgInitializer is similar to Register, but with an additional
	// newMsgFn to initialize the message data type to-be received from WebSocket
	// client, instead of letting JSON unmarshaler to guess the data type.
	RegisterWithMsgInitializer(t string, helloFn helloFnType, newMsgFn newMsgFnType) (*Service, error)
	// Unregister stops the UIChannel from processing messages with the specific type.
	Unregister(t string)
}

// Service encapsulates a way to exchange JSON messages with a specific type
// with WebSocket clients. The messages are in the form of
// `{"type": <Type>, "message": <actual message>}`.
type Service struct {
	// Type must be unique in an UIChannel
	Type string
	// In is the channel to receive messages with the specific type from the
	// clients.
	In <-chan interface{}
	// Out is the channel to send messages to the clients.
	Out      chan<- interface{}
	in       chan interface{}
	out      chan interface{}
	stopCh   chan bool
	helloFn  helloFnType
	newMsgFn newMsgFnType
	clients  *clientChannels
}

func (s *Service) writeAll() {
	// Watch for new messages and send them to the combined output.
	for {
		select {
		case <-s.stopCh:
			log.Trace("Received message on stop channel")
			return
		case msg := <-s.out:
			s.writeMsg(msg, s.clients.Out)
		}
	}
}

// writeHelloMsg writes the message created by helloFn (if exists) to the
// specified channel.
func (s *Service) writeHelloMsg(out chan<- []byte) {
	if s.helloFn != nil {
		s.helloFn(func(msg interface{}) {
			s.writeMsg(msg, out)
		})
	}
}

// writeMsg writes the specified message to the specified channel. The channel
// could fan out to all connected clients or could write to a single client,
// for example.
func (s *Service) writeMsg(msg interface{}, out chan<- []byte) {
	log.Tracef("Creating new envelope for %v", s.Type)
	b, err := newEnvelope(s.Type, msg)
	if err != nil {
		log.Error(err)
		return
	}
	log.Tracef("Sending message to clients: %v", string(b))
	out <- b
}

func NewUIChannel() UIChannel {
	c := &uiChannel{services: make(map[string]*Service)}
	c.clients = newClients(func(out chan<- []byte) {
		// This method is the callback that gets called whenever there's a new
		// incoming websocket connection.
		c.muServices.RLock()
		defer c.muServices.RUnlock()
		for _, s := range c.services {
			// Just queue the hello message for the given service for writing
			// on the new incoming websocket.
			// We put each call on a separate go routine to avoid any single hello
			// function from blocking the others, which could result in the UI
			// hanging.
			go s.writeHelloMsg(out)
		}
	})
	go c.clients.writeAll()
	go c.readLoop()

	log.Debugf("Accepting WebSocket connections")
	return c
}

type uiChannel struct {
	clients    *clientChannels
	muServices sync.RWMutex
	services   map[string]*Service
}

func (c *uiChannel) Handler() http.Handler {
	return c.clients
}

func (c *uiChannel) SendMessage(t string, data any) error {
	service := c.services[t]
	if service == nil {
		return fmt.Errorf("No service registered %s", t)
	}
	service.writeMsg(data, c.clients.Out)
	return nil
}

func (c *uiChannel) Register(t string, helloFn helloFnType) (*Service, error) {
	return c.RegisterWithMsgInitializer(t, helloFn, nil)
}

func (c *uiChannel) RegisterWithMsgInitializer(t string, helloFn helloFnType, newMsgFn newMsgFnType) (*Service, error) {
	log.Tracef("Registering UI service %s", t)

	s := &Service{
		Type:     t,
		in:       make(chan interface{}, 1000),
		out:      make(chan interface{}, 1000),
		stopCh:   make(chan bool, 1), // buffered to avoid blocking `Unregister()`
		helloFn:  helloFn,
		newMsgFn: newMsgFn,
		clients:  c.clients,
	}
	s.In, s.Out = s.in, s.out
	s.writeHelloMsg(c.clients.Out)

	c.muServices.Lock()
	defer c.muServices.Unlock()

	if c.services[t] != nil {
		// Using panic because this would be a developer error rather that
		// something that could happen naturally.
		panic("Service was already registered.")
	}

	// Adding new service to service map.
	c.services[t] = s

	log.Tracef("Registered UI service %s", t)
	go s.writeAll()
	return s, nil
}

func (c *uiChannel) Unregister(t string) {
	log.Tracef("Unregistering service: %v", t)
	c.muServices.Lock()
	defer c.muServices.Unlock()
	if c.services[t] != nil {
		c.services[t].stopCh <- true
		delete(c.services, t)
	}
}

func (c *uiChannel) readLoop() {
	for b := range c.clients.in {
		// Determining message type.
		var envType envelopeType
		err := json.Unmarshal(b, &envType)

		if err != nil {
			log.Errorf("Unable to parse JSON update from browser: %q", err)
			continue
		}

		// Delegating response to the service that registered with the given type.
		c.muServices.RLock()
		service := c.services[envType.Type]
		c.muServices.RUnlock()
		if service == nil {
			log.Errorf("Message type %v belongs to an unknown service.", envType.Type)
			continue
		}

		env := &envelope{}
		if service.newMsgFn != nil {
			env.Message = service.newMsgFn()
		}
		d := json.NewDecoder(strings.NewReader(string(b)))
		d.UseNumber()
		err = d.Decode(env)
		if err != nil {
			log.Errorf("Unable to unmarshal message of type %v: %v", envType.Type, err)
			continue
		}
		log.Tracef("Forwarding message: %v", env)
		// Pass this message and continue reading another one.
		service.in <- env.Message
	}
}

// envelopeType is the type of the message envelope.
type envelopeType struct {
	Type string `json:"type,inline"`
}

// envelope is a struct that wraps messages and associates them with a type.
type envelope struct {
	envelopeType
	Message interface{} `json:"message"`
}

func newEnvelope(t string, msg interface{}) ([]byte, error) {
	b, err := json.Marshal(&envelope{
		envelopeType: envelopeType{t},
		Message:      msg,
	})
	if err != nil {
		return nil, fmt.Errorf("Unable to marshal message of type %v: %v", t, msg)
	}
	return b, nil
}
