-- ============================================================================
-- RLS Data Migration Helper Script
-- ============================================================================
-- Use this script to assign rls_marker values to existing data when
-- transitioning from single-tenant to multi-tenant mode.
--
-- CUSTOMIZE THIS SCRIPT based on your business logic!
-- ============================================================================

-- Example 1: Assign all data to a single tenant
-- Uncomment and replace with your tenant UUID
/*
DO $$
DECLARE
    tenant_marker UUID := '00000000-0000-0000-0000-000000000001'::UUID;
BEGIN
    RAISE NOTICE 'Assigning all data to tenant: %', tenant_marker;
    
    UPDATE subscribers SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % subscribers', (SELECT COUNT(*) FROM subscribers WHERE rls_marker = tenant_marker);
    
    UPDATE lists SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % lists', (SELECT COUNT(*) FROM lists WHERE rls_marker = tenant_marker);
    
    UPDATE campaigns SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % campaigns', (SELECT COUNT(*) FROM campaigns WHERE rls_marker = tenant_marker);
    
    UPDATE templates SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % templates', (SELECT COUNT(*) FROM templates WHERE rls_marker = tenant_marker);
    
    UPDATE media SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % media', (SELECT COUNT(*) FROM media WHERE rls_marker = tenant_marker);
    
    UPDATE users SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % users', (SELECT COUNT(*) FROM users WHERE rls_marker = tenant_marker);
    
    UPDATE roles SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % roles', (SELECT COUNT(*) FROM roles WHERE rls_marker = tenant_marker);
    
    UPDATE bounces SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % bounces', (SELECT COUNT(*) FROM bounces WHERE rls_marker = tenant_marker);
    
    UPDATE subscriber_lists SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % subscriber_lists', (SELECT COUNT(*) FROM subscriber_lists WHERE rls_marker = tenant_marker);
    
    UPDATE campaign_lists SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % campaign_lists', (SELECT COUNT(*) FROM campaign_lists WHERE rls_marker = tenant_marker);
    
    UPDATE campaign_media SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % campaign_media', (SELECT COUNT(*) FROM campaign_media WHERE rls_marker = tenant_marker);
    
    UPDATE campaign_views SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % campaign_views', (SELECT COUNT(*) FROM campaign_views WHERE rls_marker = tenant_marker);
    
    UPDATE links SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % links', (SELECT COUNT(*) FROM links WHERE rls_marker = tenant_marker);
    
    UPDATE link_clicks SET rls_marker = tenant_marker WHERE rls_marker IS NULL;
    RAISE NOTICE 'Updated % link_clicks', (SELECT COUNT(*) FROM link_clicks WHERE rls_marker = tenant_marker);
    
    RAISE NOTICE 'Migration complete!';
END $$;
*/

-- Example 2: Split data by domain (e.g., email domains for subscribers)
/*
DO $$
DECLARE
    domain_marker_map JSONB := '{
        "company-a.com": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "company-b.com": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    }';
    rec RECORD;
BEGIN
    RAISE NOTICE 'Migrating subscribers by email domain...';
    
    FOR rec IN 
        SELECT id, email, 
               SPLIT_PART(email, '@', 2) AS domain
        FROM subscribers
        WHERE rls_marker IS NULL
    LOOP
        IF domain_marker_map ? rec.domain THEN
            UPDATE subscribers 
            SET rls_marker = (domain_marker_map->rec.domain)::TEXT::UUID
            WHERE id = rec.id;
        ELSE
            RAISE NOTICE 'No marker mapping for domain: %', rec.domain;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Subscriber migration complete!';
END $$;
*/

-- Example 3: Assign markers based on external table (tenant_mappings)
/*
-- First, create a mapping table (temporary)
CREATE TEMP TABLE tenant_mappings (
    user_id INT,
    list_id INT,
    tenant_uuid UUID
);

-- Load your mappings
INSERT INTO tenant_mappings (user_id, tenant_uuid) VALUES
    (1, '11111111-1111-1111-1111-111111111111'),
    (2, '22222222-2222-2222-2222-222222222222');

-- Apply mappings
UPDATE users u
SET rls_marker = tm.tenant_uuid
FROM tenant_mappings tm
WHERE u.id = tm.user_id AND u.rls_marker IS NULL;

DROP TABLE tenant_mappings;
*/

-- Example 4: Keep certain data global (NULL marker)
/*
DO $$
BEGIN
    RAISE NOTICE 'Keeping system templates as global...';
    
    UPDATE templates 
    SET rls_marker = NULL
    WHERE name LIKE 'System:%';
    
    RAISE NOTICE 'Kept % templates as global', 
        (SELECT COUNT(*) FROM templates WHERE rls_marker IS NULL);
END $$;
*/

-- ============================================================================
-- Verification Query
-- ============================================================================
-- Run this after migration to verify marker distribution

SELECT 
    'subscribers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(rls_marker) AS rows_with_marker,
    COUNT(*) - COUNT(rls_marker) AS rows_without_marker,
    COUNT(DISTINCT rls_marker) AS unique_markers
FROM subscribers

UNION ALL

SELECT 
    'lists',
    COUNT(*),
    COUNT(rls_marker),
    COUNT(*) - COUNT(rls_marker),
    COUNT(DISTINCT rls_marker)
FROM lists

UNION ALL

SELECT 
    'campaigns',
    COUNT(*),
    COUNT(rls_marker),
    COUNT(*) - COUNT(rls_marker),
    COUNT(DISTINCT rls_marker)
FROM campaigns

UNION ALL

SELECT 
    'templates',
    COUNT(*),
    COUNT(rls_marker),
    COUNT(*) - COUNT(rls_marker),
    COUNT(DISTINCT rls_marker)
FROM templates

UNION ALL

SELECT 
    'media',
    COUNT(*),
    COUNT(rls_marker),
    COUNT(*) - COUNT(rls_marker),
    COUNT(DISTINCT rls_marker)
FROM media

UNION ALL

SELECT 
    'users',
    COUNT(*),
    COUNT(rls_marker),
    COUNT(*) - COUNT(rls_marker),
    COUNT(DISTINCT rls_marker)
FROM users

ORDER BY table_name;
