package mailgun

// Package mailgun provides Mailgun API integration.
//
// NOTE: This is a community-contributed integration with minimal testing.
// For production use, please test thoroughly in your environment.
// Pull requests welcome!
//
// Configuration example (config.toml):
//   [[messengers]]
//   enabled = true
//   name = "mailgun"
//   api_key = "your-mailgun-api-key"
//   domain = "your-domain.com"

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/knadh/listmonk/models"
	"github.com/mailgun/mailgun-go/v4"
)

const (
	MessengerName = "mailgun"
)

// Messenger is the Mailgun API messenger.
type Messenger struct {
	name   string
	mg     *mailgun.MailgunImpl
	logger *log.Logger
}

// Config contains configuration for the Mailgun messenger.
type Config struct {
	Name   string
	APIKey string
	Domain string
	// Optional: Set to "eu" for EU region, leave empty for US
	Region string
}

// New creates a new Mailgun messenger.
func New(cfg Config, logger *log.Logger) (*Messenger, error) {
	if cfg.Name == "" {
		cfg.Name = MessengerName
	}

	if cfg.APIKey == "" {
		return nil, fmt.Errorf("mailgun: API key is required")
	}

	if cfg.Domain == "" {
		return nil, fmt.Errorf("mailgun: domain is required")
	}

	mg := mailgun.NewMailgun(cfg.Domain, cfg.APIKey)

	// Set EU region if specified
	if cfg.Region == "eu" {
		mg.SetAPIBase(mailgun.APIBaseEU)
	}

	return &Messenger{
		name:   cfg.Name,
		mg:     mg,
		logger: logger,
	}, nil
}

// Name returns the messenger's name.
func (m *Messenger) Name() string {
	return m.name
}

// Push sends a message via Mailgun API.
// Basic implementation - community contributed, minimal testing.
func (m *Messenger) Push(msg models.Message) error {
	if len(msg.To) == 0 {
		return fmt.Errorf("mailgun: no recipients")
	}

	// Create message
	var textBody string
	if msg.ContentType == "plain" {
		textBody = string(msg.Body)
	} else if len(msg.AltBody) > 0 {
		textBody = string(msg.AltBody)
	}

	message := m.mg.NewMessage(
		msg.From,
		msg.Subject,
		textBody,
		msg.To[0],
	)

	// Set HTML body if not plain text
	if msg.ContentType != "plain" {
		message.SetHtml(string(msg.Body))
	}

	// Send it with 10 second timeout
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	_, _, err := m.mg.Send(ctx, message)
	if err != nil {
		return fmt.Errorf("mailgun: %w", err)
	}

	return nil
}

// Flush is a no-op for Mailgun (synchronous API).
func (m *Messenger) Flush() error {
	return nil
}

// Close is a no-op for Mailgun.
func (m *Messenger) Close() error {
	return nil
}
