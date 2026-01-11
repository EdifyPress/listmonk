-- ============================================================================
-- ListMonk Row-Level Security (RLS) Policy Definitions
-- ============================================================================
-- This script defines PostgreSQL RLS policies for multi-tenant isolation.
-- 
-- IMPORTANT: This is a GENERIC RLS implementation. It does NOT contain
-- any tenant provisioning or business logic. External services (like a
-- Tenant Broker) are responsible for setting session variables.
--
-- Usage:
--   1. Enable RLS on tables (run enable-rls.sql)
--   2. Apply policies (run this script)
--   3. Configure app with rls.enabled = true
--   4. External service sets: SET SESSION app.current_marker = '<uuid>';
--
-- ============================================================================

-- ============================================================================
-- Helper function to get current RLS marker from session variable
-- ============================================================================
CREATE OR REPLACE FUNCTION get_current_rls_marker()
RETURNS UUID AS $$
DECLARE
    marker_text TEXT;
BEGIN
    -- Get the session variable as text
    marker_text := current_setting('app.current_marker', true);
    
    -- If not set or empty, return NULL (allows global access in non-RLS mode)
    IF marker_text IS NULL OR marker_text = '' THEN
        RETURN NULL;
    END IF;
    
    -- Convert to UUID and return
    RETURN marker_text::UUID;
EXCEPTION
    WHEN OTHERS THEN
        -- If conversion fails, log and return NULL
        RAISE WARNING 'Invalid UUID format in app.current_marker: %', marker_text;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- RLS Policies for Core Tables
-- ============================================================================

-- Subscribers
DROP POLICY IF EXISTS rls_subscribers_select ON subscribers;
CREATE POLICY rls_subscribers_select ON subscribers
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscribers_insert ON subscribers;
CREATE POLICY rls_subscribers_insert ON subscribers
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscribers_update ON subscribers;
CREATE POLICY rls_subscribers_update ON subscribers
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscribers_delete ON subscribers;
CREATE POLICY rls_subscribers_delete ON subscribers
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Lists
DROP POLICY IF EXISTS rls_lists_select ON lists;
CREATE POLICY rls_lists_select ON lists
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_lists_insert ON lists;
CREATE POLICY rls_lists_insert ON lists
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_lists_update ON lists;
CREATE POLICY rls_lists_update ON lists
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_lists_delete ON lists;
CREATE POLICY rls_lists_delete ON lists
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Campaigns
DROP POLICY IF EXISTS rls_campaigns_select ON campaigns;
CREATE POLICY rls_campaigns_select ON campaigns
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaigns_insert ON campaigns;
CREATE POLICY rls_campaigns_insert ON campaigns
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaigns_update ON campaigns;
CREATE POLICY rls_campaigns_update ON campaigns
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaigns_delete ON campaigns;
CREATE POLICY rls_campaigns_delete ON campaigns
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Templates
DROP POLICY IF EXISTS rls_templates_select ON templates;
CREATE POLICY rls_templates_select ON templates
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_templates_insert ON templates;
CREATE POLICY rls_templates_insert ON templates
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_templates_update ON templates;
CREATE POLICY rls_templates_update ON templates
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_templates_delete ON templates;
CREATE POLICY rls_templates_delete ON templates
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Media
DROP POLICY IF EXISTS rls_media_select ON media;
CREATE POLICY rls_media_select ON media
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_media_insert ON media;
CREATE POLICY rls_media_insert ON media
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_media_update ON media;
CREATE POLICY rls_media_update ON media
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_media_delete ON media;
CREATE POLICY rls_media_delete ON media
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Users
DROP POLICY IF EXISTS rls_users_select ON users;
CREATE POLICY rls_users_select ON users
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_users_insert ON users;
CREATE POLICY rls_users_insert ON users
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_users_update ON users;
CREATE POLICY rls_users_update ON users
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_users_delete ON users;
CREATE POLICY rls_users_delete ON users
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Roles
DROP POLICY IF EXISTS rls_roles_select ON roles;
CREATE POLICY rls_roles_select ON roles
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_roles_insert ON roles;
CREATE POLICY rls_roles_insert ON roles
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_roles_update ON roles;
CREATE POLICY rls_roles_update ON roles
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_roles_delete ON roles;
CREATE POLICY rls_roles_delete ON roles
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Bounces
DROP POLICY IF EXISTS rls_bounces_select ON bounces;
CREATE POLICY rls_bounces_select ON bounces
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_bounces_insert ON bounces;
CREATE POLICY rls_bounces_insert ON bounces
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_bounces_update ON bounces;
CREATE POLICY rls_bounces_update ON bounces
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_bounces_delete ON bounces;
CREATE POLICY rls_bounces_delete ON bounces
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- ============================================================================
-- RLS Policies for Junction Tables
-- ============================================================================

-- Subscriber Lists
DROP POLICY IF EXISTS rls_subscriber_lists_select ON subscriber_lists;
CREATE POLICY rls_subscriber_lists_select ON subscriber_lists
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscriber_lists_insert ON subscriber_lists;
CREATE POLICY rls_subscriber_lists_insert ON subscriber_lists
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscriber_lists_update ON subscriber_lists;
CREATE POLICY rls_subscriber_lists_update ON subscriber_lists
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_subscriber_lists_delete ON subscriber_lists;
CREATE POLICY rls_subscriber_lists_delete ON subscriber_lists
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Campaign Lists
DROP POLICY IF EXISTS rls_campaign_lists_select ON campaign_lists;
CREATE POLICY rls_campaign_lists_select ON campaign_lists
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_lists_insert ON campaign_lists;
CREATE POLICY rls_campaign_lists_insert ON campaign_lists
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_lists_update ON campaign_lists;
CREATE POLICY rls_campaign_lists_update ON campaign_lists
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_lists_delete ON campaign_lists;
CREATE POLICY rls_campaign_lists_delete ON campaign_lists
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Campaign Media
DROP POLICY IF EXISTS rls_campaign_media_select ON campaign_media;
CREATE POLICY rls_campaign_media_select ON campaign_media
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_media_insert ON campaign_media;
CREATE POLICY rls_campaign_media_insert ON campaign_media
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_media_update ON campaign_media;
CREATE POLICY rls_campaign_media_update ON campaign_media
    FOR UPDATE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_media_delete ON campaign_media;
CREATE POLICY rls_campaign_media_delete ON campaign_media
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- ============================================================================
-- RLS Policies for Tracking Tables
-- ============================================================================

-- Campaign Views
DROP POLICY IF EXISTS rls_campaign_views_select ON campaign_views;
CREATE POLICY rls_campaign_views_select ON campaign_views
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_views_insert ON campaign_views;
CREATE POLICY rls_campaign_views_insert ON campaign_views
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_campaign_views_delete ON campaign_views;
CREATE POLICY rls_campaign_views_delete ON campaign_views
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Links
DROP POLICY IF EXISTS rls_links_select ON links;
CREATE POLICY rls_links_select ON links
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_links_insert ON links;
CREATE POLICY rls_links_insert ON links
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_links_delete ON links;
CREATE POLICY rls_links_delete ON links
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- Link Clicks
DROP POLICY IF EXISTS rls_link_clicks_select ON link_clicks;
CREATE POLICY rls_link_clicks_select ON link_clicks
    FOR SELECT
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_link_clicks_insert ON link_clicks;
CREATE POLICY rls_link_clicks_insert ON link_clicks
    FOR INSERT
    WITH CHECK (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

DROP POLICY IF EXISTS rls_link_clicks_delete ON link_clicks;
CREATE POLICY rls_link_clicks_delete ON link_clicks
    FOR DELETE
    USING (rls_marker IS NULL OR rls_marker = get_current_rls_marker());

-- ============================================================================
-- Verification
-- ============================================================================
DO $$
BEGIN
    RAISE NOTICE 'RLS policies created successfully';
    RAISE NOTICE 'Use enable-rls.sql to activate RLS on tables';
    RAISE NOTICE 'External services must set: SET SESSION app.current_marker = ''<uuid>'';';
END $$;
