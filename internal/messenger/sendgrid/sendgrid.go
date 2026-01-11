package sendgrid

// Package sendgrid provides SendGrid API integration.
//
// NOTE: This is a community-contributed integration with minimal testing.
// For production use, please test thoroughly in your environment.
// Pull requests welcome!
//
// Configuration example (config.toml):
//   [[messengers]]
//   enabled = true
//   name = "sendgrid"
//   api_key = "your-sendgrid-api-key"

import (
	"fmt"
	"log"

	"github.com/knadh/listmonk/models"
	"github.com/sendgrid/sendgrid-go"
	"github.com/sendgrid/sendgrid-go/helpers/mail"
)

const (
	MessengerName = "sendgrid"
)

// Messenger is the SendGrid API messenger.
type Messenger struct {
	name   string
	client *sendgrid.Client
	logger *log.Logger
}

// Config contains configuration for the SendGrid messenger.
type Config struct {
	Name   string
	APIKey string
}

// New creates a new SendGrid messenger.
func New(cfg Config, logger *log.Logger) (*Messenger, error) {
	if cfg.Name == "" {
		cfg.Name = MessengerName
	}

	if cfg.APIKey == "" {
		return nil, fmt.Errorf("sendgrid: API key is required")
	}

	return &Messenger{
		name:   cfg.Name,
		client: sendgrid.NewSendClient(cfg.APIKey),
		logger: logger,
	}, nil
}

// Name returns the messenger's name.
func (m *Messenger) Name() string {
	return m.name
}

// Push sends a message via SendGrid API.
// Basic implementation - community contributed, minimal testing.
func (m *Messenger) Push(msg models.Message) error {
	if len(msg.To) == 0 {
		return fmt.Errorf("sendgrid: no recipients")
	}

	// SendGrid basic single email - just get it sent
	from := mail.NewEmail("", msg.From)
	to := mail.NewEmail("", msg.To[0])

	var content *mail.Content
	if msg.ContentType == "plain" {
		content = mail.NewContent("text/plain", string(msg.Body))
	} else {
		content = mail.NewContent("text/html", string(msg.Body))
	}

	message := mail.NewV3MailInit(from, msg.Subject, to, content)

	// Add alt body if provided
	if len(msg.AltBody) > 0 && msg.ContentType != "plain" {
		message.AddContent(mail.NewContent("text/plain", string(msg.AltBody)))
	}

	// Send it
	resp, err := m.client.Send(message)
	if err != nil {
		return fmt.Errorf("sendgrid: %w", err)
	}

	// Check for errors in response
	if resp.StatusCode >= 400 {
		return fmt.Errorf("sendgrid: API returned status %d: %s", resp.StatusCode, resp.Body)
	}

	return nil
}

// Flush is a no-op for SendGrid (synchronous API).
func (m *Messenger) Flush() error {
	return nil
}

// Close is a no-op for SendGrid.
func (m *Messenger) Close() error {
	return nil
}
