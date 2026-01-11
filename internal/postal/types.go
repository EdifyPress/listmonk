package postal

import "time"

// SendMessageRequest represents a request to send an email via Postal API.
type SendMessageRequest struct {
	To          []string          `json:"to"`
	From        string            `json:"from"`
	Subject     string            `json:"subject"`
	PlainBody   string            `json:"plain_body,omitempty"`
	HTMLBody    string            `json:"html_body,omitempty"`
	Tag         string            `json:"tag,omitempty"`
	Headers     map[string]string `json:"headers,omitempty"`
	Attachments []Attachment      `json:"attachments,omitempty"`
}

// Attachment represents an email attachment.
type Attachment struct {
	Name        string `json:"name"`
	ContentType string `json:"content_type"`
	Data        string `json:"data"` // Base64 encoded
}

// SendMessageResponse represents the response from Postal API.
type SendMessageResponse struct {
	Status   string                    `json:"status"`
	Time     float64                   `json:"time"`
	Flags    map[string]bool           `json:"flags"`
	Data     SendMessageResponseData   `json:"data"`
	Messages []SendMessageResponseItem `json:"messages"`
}

// SendMessageResponseData contains the message details.
type SendMessageResponseData struct {
	MessageID string `json:"message_id"`
	Messages  map[string]MessageDetails
}

// MessageDetails contains details about a sent message.
type MessageDetails struct {
	ID    int    `json:"id"`
	Token string `json:"token"`
}

// SendMessageResponseItem contains details for each recipient.
type SendMessageResponseItem struct {
	ID     int    `json:"id"`
	Token  string `json:"token"`
	Status string `json:"status"`
}

// ErrorResponse represents an error from Postal API.
type ErrorResponse struct {
	Status string                 `json:"status"`
	Time   float64                `json:"time"`
	Data   map[string]interface{} `json:"data"`
}

// WebhookPayload represents the payload from a Postal webhook.
type WebhookPayload struct {
	Event     string      `json:"event"`
	Timestamp float64     `json:"timestamp"`
	Payload   interface{} `json:"payload"`
	UUID      string      `json:"uuid"`
}

// MessageSentPayload represents the payload for a MessageSent event.
type MessageSentPayload struct {
	Message   WebhookMessage `json:"message"`
	Status    string         `json:"status"`
	Details   string         `json:"details"`
	Output    string         `json:"output"`
	SentWithSSL bool         `json:"sent_with_ssl"`
	Timestamp float64        `json:"timestamp"`
}

// MessageDeliveryFailedPayload represents the payload for a MessageDeliveryFailed event.
type MessageDeliveryFailedPayload struct {
	Message   WebhookMessage `json:"message"`
	Status    string         `json:"status"`
	Details   string         `json:"details"`
	Output    string         `json:"output"`
	Timestamp float64        `json:"timestamp"`
}

// MessageBouncedPayload represents the payload for a MessageBounced event.
type MessageBouncedPayload struct {
	OriginalMessage WebhookMessage `json:"original_message"`
	Bounce          BounceDetails  `json:"bounce"`
}

// MessageLinkClickedPayload represents the payload for a MessageLinkClicked event.
type MessageLinkClickedPayload struct {
	Message   WebhookMessage `json:"message"`
	URL       string         `json:"url"`
	Token     string         `json:"token"`
	IPAddress string         `json:"ip_address"`
	UserAgent string         `json:"user_agent"`
}

// WebhookMessage represents a message in a webhook payload.
type WebhookMessage struct {
	ID         int       `json:"id"`
	Token      string    `json:"token"`
	Direction  string    `json:"direction"`
	MessageID  string    `json:"message_id"`
	To         string    `json:"to"`
	From       string    `json:"from"`
	Subject    string    `json:"subject"`
	Timestamp  float64   `json:"timestamp"`
	SpamStatus string    `json:"spam_status"`
	Tag        string    `json:"tag"`
}

// BounceDetails represents bounce information.
type BounceDetails struct {
	ID              int    `json:"id"`
	Token           string `json:"token"`
	BounceMessageID string `json:"bounce_message_id"`
}

// TagInfo represents parsed tag information.
type TagInfo struct {
	TenantID     int
	CampaignID   int
	SubscriberID int64
	Valid        bool
}

// Time converts Unix timestamp to Go time.Time.
func (w *WebhookMessage) Time() time.Time {
	return time.Unix(int64(w.Timestamp), 0)
}
