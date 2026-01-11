-- ============================================================================
-- Disable Row-Level Security (RLS) on ListMonk Tables
-- ============================================================================
-- This script disables RLS on all data tables.
-- Use this to revert to non-RLS mode or for troubleshooting.
-- ============================================================================

-- Disable RLS on core tables
ALTER TABLE subscribers DISABLE ROW LEVEL SECURITY;
ALTER TABLE lists DISABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns DISABLE ROW LEVEL SECURITY;
ALTER TABLE templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE media DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE bounces DISABLE ROW LEVEL SECURITY;

-- Disable RLS on junction tables
ALTER TABLE subscriber_lists DISABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_lists DISABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_media DISABLE ROW LEVEL SECURITY;

-- Disable RLS on tracking tables
ALTER TABLE campaign_views DISABLE ROW LEVEL SECURITY;
ALTER TABLE links DISABLE ROW LEVEL SECURITY;
ALTER TABLE link_clicks DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE '=== RLS Status Check ===';
    FOR rec IN 
        SELECT tablename, rowsecurity 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename IN (
            'subscribers', 'lists', 'campaigns', 'templates', 'media',
            'users', 'roles', 'bounces', 'subscriber_lists', 'campaign_lists',
            'campaign_media', 'campaign_views', 'links', 'link_clicks'
        )
        ORDER BY tablename
    LOOP
        RAISE NOTICE 'Table: % - RLS Enabled: %', rec.tablename, rec.rowsecurity;
    END LOOP;
    RAISE NOTICE '=== End RLS Status ===';
    RAISE NOTICE '';
    RAISE NOTICE 'RLS is now DISABLED. All rows are accessible without filtering.';
END $$;
