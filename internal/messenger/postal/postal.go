package postal

import (
	"encoding/base64"
	"fmt"
	"log"

	"github.com/knadh/listmonk/internal/postal"
	"github.com/knadh/listmonk/models"
)

const (
	MessengerName = "postal"
)

// Messenger is the Postal messenger for sending emails via Postal API.
type Messenger struct {
	client *postal.Client
	name   string
	logger *log.Logger
}

// Config contains configuration for the Postal messenger.
type Config struct {
	Name    string
	BaseURL string
	APIKey  string
}

// New creates a new Postal messenger.
func New(cfg Config, logger *log.Logger) (*Messenger, error) {
	if cfg.Name == "" {
		cfg.Name = MessengerName
	}

	client, err := postal.New(postal.Config{
		BaseURL: cfg.BaseURL,
		APIKey:  cfg.APIKey,
	})
	if err != nil {
		return nil, fmt.Errorf("postal messenger: %w", err)
	}

	return &Messenger{
		client: client,
		name:   cfg.Name,
		logger: logger,
	}, nil
}

// Name returns the messenger's name.
func (m *Messenger) Name() string {
	return m.name
}

// Push sends a message via Postal API.
func (m *Messenger) Push(msg models.Message) error {
	// Build the request
	req := postal.SendMessageRequest{
		To:      msg.To,
		From:    msg.From,
		Subject: msg.Subject,
	}

	// Set body based on content type
	switch msg.ContentType {
	case "plain":
		req.PlainBody = string(msg.Body)
	default:
		req.HTMLBody = string(msg.Body)
		if len(msg.AltBody) > 0 {
			req.PlainBody = string(msg.AltBody)
		}
	}

	// Add headers
	if len(msg.Headers) > 0 {
		req.Headers = make(map[string]string)
		for k, v := range msg.Headers {
			if len(v) > 0 {
				req.Headers[k] = v[0]
			}
		}
	}

	// Create tracking tag if this is a campaign message
	if msg.Campaign != nil {
		// Extract tenant ID from campaign if available (for multi-tenant support)
		// For now, we'll use 0 for single-tenant or add tenant_id to Campaign model later
		tenantID := 0
		req.Tag = postal.MakeTag(tenantID, msg.Campaign.ID, int64(msg.Subscriber.ID))
	}

	// Add attachments
	if len(msg.Attachments) > 0 {
		req.Attachments = make([]postal.Attachment, 0, len(msg.Attachments))
		for _, att := range msg.Attachments {
			req.Attachments = append(req.Attachments, postal.Attachment{
				Name:        att.Name,
				ContentType: att.Header.Get("Content-Type"),
				Data:        base64.StdEncoding.EncodeToString(att.Content),
			})
		}
	}

	// Send via Postal
	resp, err := m.client.SendMessage(req)
	if err != nil {
		return fmt.Errorf("postal: failed to send message: %w", err)
	}

	// Log successful send
	if m.logger != nil && msg.Campaign != nil {
		m.logger.Printf("postal: sent campaign=%d subscriber=%d message_id=%s",
			msg.Campaign.ID, msg.Subscriber.ID, resp.Data.MessageID)
	}

	return nil
}

// Flush is a no-op for Postal as messages are sent immediately.
func (m *Messenger) Flush() error {
	return nil
}

// Close closes the Postal client.
func (m *Messenger) Close() error {
	m.client.Close()
	return nil
}
