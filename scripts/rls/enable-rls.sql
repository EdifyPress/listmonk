-- ============================================================================
-- Enable Row-Level Security (RLS) on ListMonk Tables
-- ============================================================================
-- This script enables RLS on all data tables. Run this AFTER:
--   1. Migration v6.1.0 has been applied (adds rls_marker columns)
--   2. create-policies.sql has been run (defines policies)
--
-- WARNING: Once enabled, queries will be filtered by app.current_marker
-- session variable. Ensure your application or proxy sets this variable!
-- ============================================================================

-- Enable RLS on core tables
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bounces ENABLE ROW LEVEL SECURITY;

-- Enable RLS on junction tables
ALTER TABLE subscriber_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_media ENABLE ROW LEVEL SECURITY;

-- Enable RLS on tracking tables
ALTER TABLE campaign_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE links ENABLE ROW LEVEL SECURITY;
ALTER TABLE link_clicks ENABLE ROW LEVEL SECURITY;

-- Settings and sessions tables are intentionally NOT RLS-protected
-- as they are application-wide configuration

-- Verify RLS is enabled
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
    RAISE NOTICE 'RLS is now ACTIVE. External services must set session variable:';
    RAISE NOTICE '  SET SESSION app.current_marker = ''<uuid>'';';
END $$;
