package postal

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestSendMessage(t *testing.T) {
	// Create a mock Postal API server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify the request
		if r.Method != http.MethodPost {
			t.Errorf("Expected POST request, got %s", r.Method)
		}

		if r.URL.Path != "/api/v1/send/message" {
			t.Errorf("Expected path /api/v1/send/message, got %s", r.URL.Path)
		}

		apiKey := r.Header.Get("X-Server-API-Key")
		if apiKey != "test-api-key" {
			t.Errorf("Expected API key 'test-api-key', got %s", apiKey)
		}

		// Parse the request body
		var req map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("Failed to decode request body: %v", err)
		}

		// Send a mock success response
		resp := SendMessageResponse{
			Status: "success",
			Time:   0.123,
			Data: SendMessageResponseData{
				MessageID: "test-message-id",
			},
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	// Create a client pointing to the mock server
	client, err := New(Config{
		BaseURL: server.URL,
		APIKey:  "test-api-key",
	})
	if err != nil {
		t.Fatalf("Failed to create client: %v", err)
	}

	// Test sending a message
	req := SendMessageRequest{
		To:        []string{"test@example.com"},
		From:      "sender@example.com",
		Subject:   "Test Subject",
		HTMLBody:  "<p>Test Body</p>",
		PlainBody: "Test Body",
		Tag:       "campaign-123-subscriber-456",
	}

	resp, err := client.SendMessage(req)
	if err != nil {
		t.Fatalf("SendMessage failed: %v", err)
	}

	if resp.Status != "success" {
		t.Errorf("Expected status 'success', got %s", resp.Status)
	}

	if resp.Data.MessageID != "test-message-id" {
		t.Errorf("Expected message_id 'test-message-id', got %s", resp.Data.MessageID)
	}
}

func TestSendMessage_Error(t *testing.T) {
	// Create a mock server that returns an error
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		resp := ErrorResponse{
			Status: "error",
			Time:   0.123,
			Data: map[string]interface{}{
				"message": "Invalid request",
			},
		}
		json.NewEncoder(w).Encode(resp)
	}))
	defer server.Close()

	client, err := New(Config{
		BaseURL: server.URL,
		APIKey:  "test-api-key",
	})
	if err != nil {
		t.Fatalf("Failed to create client: %v", err)
	}

	req := SendMessageRequest{
		To:      []string{"test@example.com"},
		From:    "sender@example.com",
		Subject: "Test",
	}

	_, err = client.SendMessage(req)
	if err == nil {
		t.Fatal("Expected error, got nil")
	}
}

func TestNew_MissingConfig(t *testing.T) {
	tests := []struct {
		name   string
		config Config
	}{
		{
			name: "missing base URL",
			config: Config{
				BaseURL: "",
				APIKey:  "test-key",
			},
		},
		{
			name: "missing API key",
			config: Config{
				BaseURL: "http://localhost",
				APIKey:  "",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := New(tt.config)
			if err == nil {
				t.Error("Expected error for missing config, got nil")
			}
		})
	}
}
