package postal

import (
	"testing"
)

func TestParseTag(t *testing.T) {
	tests := []struct {
		name     string
		tag      string
		expected TagInfo
	}{
		{
			name: "valid multi-tenant tag",
			tag:  "tenant-123-campaign-456-subscriber-789",
			expected: TagInfo{
				TenantID:     123,
				CampaignID:   456,
				SubscriberID: 789,
				Valid:        true,
			},
		},
		{
			name: "valid single-tenant tag",
			tag:  "campaign-456-subscriber-789",
			expected: TagInfo{
				TenantID:     0,
				CampaignID:   456,
				SubscriberID: 789,
				Valid:        true,
			},
		},
		{
			name: "empty tag",
			tag:  "",
			expected: TagInfo{
				Valid: false,
			},
		},
		{
			name: "invalid format",
			tag:  "invalid-tag-format",
			expected: TagInfo{
				Valid: false,
			},
		},
		{
			name: "invalid tenant id",
			tag:  "tenant-abc-campaign-456-subscriber-789",
			expected: TagInfo{
				Valid: false,
			},
		},
		{
			name: "invalid campaign id",
			tag:  "campaign-abc-subscriber-789",
			expected: TagInfo{
				Valid: false,
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := ParseTag(tt.tag)
			if result.Valid != tt.expected.Valid {
				t.Errorf("Valid: got %v, want %v", result.Valid, tt.expected.Valid)
			}
			if result.Valid {
				if result.TenantID != tt.expected.TenantID {
					t.Errorf("TenantID: got %d, want %d", result.TenantID, tt.expected.TenantID)
				}
				if result.CampaignID != tt.expected.CampaignID {
					t.Errorf("CampaignID: got %d, want %d", result.CampaignID, tt.expected.CampaignID)
				}
				if result.SubscriberID != tt.expected.SubscriberID {
					t.Errorf("SubscriberID: got %d, want %d", result.SubscriberID, tt.expected.SubscriberID)
				}
			}
		})
	}
}

func TestMakeTag(t *testing.T) {
	tests := []struct {
		name         string
		tenantID     int
		campaignID   int
		subscriberID int64
		expected     string
	}{
		{
			name:         "multi-tenant tag",
			tenantID:     123,
			campaignID:   456,
			subscriberID: 789,
			expected:     "tenant-123-campaign-456-subscriber-789",
		},
		{
			name:         "single-tenant tag",
			tenantID:     0,
			campaignID:   456,
			subscriberID: 789,
			expected:     "campaign-456-subscriber-789",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := MakeTag(tt.tenantID, tt.campaignID, tt.subscriberID)
			if result != tt.expected {
				t.Errorf("got %q, want %q", result, tt.expected)
			}
		})
	}
}

func TestTagRoundtrip(t *testing.T) {
	tests := []struct {
		tenantID     int
		campaignID   int
		subscriberID int64
	}{
		{123, 456, 789},
		{0, 456, 789},
		{1, 1, 1},
		{999, 999, 999},
	}

	for _, tt := range tests {
		tag := MakeTag(tt.tenantID, tt.campaignID, tt.subscriberID)
		info := ParseTag(tag)

		if !info.Valid {
			t.Errorf("Tag should be valid: %s", tag)
		}
		if info.TenantID != tt.tenantID {
			t.Errorf("TenantID: got %d, want %d", info.TenantID, tt.tenantID)
		}
		if info.CampaignID != tt.campaignID {
			t.Errorf("CampaignID: got %d, want %d", info.CampaignID, tt.campaignID)
		}
		if info.SubscriberID != tt.subscriberID {
			t.Errorf("SubscriberID: got %d, want %d", info.SubscriberID, tt.subscriberID)
		}
	}
}
