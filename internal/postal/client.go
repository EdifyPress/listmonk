package postal

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const (
	defaultTimeout = 30 * time.Second
)

// Client is a Postal API client.
type Client struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

// Config contains configuration for the Postal client.
type Config struct {
	BaseURL string
	APIKey  string
	Timeout time.Duration
}

// New creates a new Postal API client.
func New(cfg Config) (*Client, error) {
	if cfg.BaseURL == "" {
		return nil, fmt.Errorf("postal: base URL is required")
	}
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("postal: API key is required")
	}

	timeout := cfg.Timeout
	if timeout == 0 {
		timeout = defaultTimeout
	}

	return &Client{
		baseURL: cfg.BaseURL,
		apiKey:  cfg.APIKey,
		httpClient: &http.Client{
			Timeout: timeout,
			Transport: &http.Transport{
				MaxIdleConns:        100,
				MaxIdleConnsPerHost: 10,
				IdleConnTimeout:     90 * time.Second,
			},
		},
	}, nil
}

// SendMessage sends an email via the Postal API.
func (c *Client) SendMessage(req SendMessageRequest) (*SendMessageResponse, error) {
	// Postal expects the request in a specific format
	payload := map[string]interface{}{
		"to":      req.To,
		"from":    req.From,
		"subject": req.Subject,
	}

	if req.PlainBody != "" {
		payload["plain_body"] = req.PlainBody
	}
	if req.HTMLBody != "" {
		payload["html_body"] = req.HTMLBody
	}
	if req.Tag != "" {
		payload["tag"] = req.Tag
	}
	if len(req.Headers) > 0 {
		payload["headers"] = req.Headers
	}
	if len(req.Attachments) > 0 {
		payload["attachments"] = req.Attachments
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("postal: failed to marshal request: %w", err)
	}

	httpReq, err := http.NewRequest(http.MethodPost, c.baseURL+"/api/v1/send/message", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("postal: failed to create request: %w", err)
	}

	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("X-Server-API-Key", c.apiKey)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("postal: request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("postal: failed to read response: %w", err)
	}

	// Check for HTTP errors
	if resp.StatusCode != http.StatusOK {
		var errResp ErrorResponse
		if err := json.Unmarshal(respBody, &errResp); err != nil {
			return nil, fmt.Errorf("postal: API error (status %d): %s", resp.StatusCode, string(respBody))
		}
		return nil, fmt.Errorf("postal: API error (status %d): %v", resp.StatusCode, errResp.Data)
	}

	var result SendMessageResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("postal: failed to unmarshal response: %w", err)
	}

	if result.Status != "success" {
		return nil, fmt.Errorf("postal: send failed with status: %s", result.Status)
	}

	return &result, nil
}

// Close closes idle connections.
func (c *Client) Close() {
	c.httpClient.CloseIdleConnections()
}
