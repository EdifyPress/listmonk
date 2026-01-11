package postal

import (
	"fmt"
	"strconv"
	"strings"
)

// ParseTag parses a Postal tag in the format:
// tenant-{tenant_id}-campaign-{campaign_id}-subscriber-{subscriber_id}
// or just: campaign-{campaign_id}-subscriber-{subscriber_id}
//
// Returns TagInfo with parsed values.
func ParseTag(tag string) TagInfo {
	info := TagInfo{Valid: false}

	if tag == "" {
		return info
	}

	parts := strings.Split(tag, "-")
	
	// Support both formats:
	// 1. tenant-{tid}-campaign-{cid}-subscriber-{sid} (6 parts)
	// 2. campaign-{cid}-subscriber-{sid} (4 parts)
	
	if len(parts) == 6 {
		// Format: tenant-{tid}-campaign-{cid}-subscriber-{sid}
		if parts[0] != "tenant" || parts[2] != "campaign" || parts[4] != "subscriber" {
			return info
		}

		tenantID, err := strconv.Atoi(parts[1])
		if err != nil {
			return info
		}

		campaignID, err := strconv.Atoi(parts[3])
		if err != nil {
			return info
		}

		subscriberID, err := strconv.ParseInt(parts[5], 10, 64)
		if err != nil {
			return info
		}

		info.TenantID = tenantID
		info.CampaignID = campaignID
		info.SubscriberID = subscriberID
		info.Valid = true

	} else if len(parts) == 4 {
		// Format: campaign-{cid}-subscriber-{sid} (legacy/single-tenant)
		if parts[0] != "campaign" || parts[2] != "subscriber" {
			return info
		}

		campaignID, err := strconv.Atoi(parts[1])
		if err != nil {
			return info
		}

		subscriberID, err := strconv.ParseInt(parts[3], 10, 64)
		if err != nil {
			return info
		}

		info.TenantID = 0 // Single-tenant or not specified
		info.CampaignID = campaignID
		info.SubscriberID = subscriberID
		info.Valid = true
	}

	return info
}

// MakeTag creates a Postal tag for tracking.
func MakeTag(tenantID, campaignID int, subscriberID int64) string {
	if tenantID > 0 {
		return fmt.Sprintf("tenant-%d-campaign-%d-subscriber-%d", tenantID, campaignID, subscriberID)
	}
	return fmt.Sprintf("campaign-%d-subscriber-%d", campaignID, subscriberID)
}
