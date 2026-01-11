-- ============================================================================
-- RLS Testing and Verification Script
-- ============================================================================
-- This script tests RLS policies to ensure proper isolation.
-- Run this AFTER enable-rls.sql to verify your setup.
-- ============================================================================

-- Create test markers
DO $$
DECLARE
    marker1 UUID := gen_random_uuid();
    marker2 UUID := gen_random_uuid();
    test_sub_id1 INT;
    test_sub_id2 INT;
    test_list_id1 INT;
    test_list_id2 INT;
BEGIN
    RAISE NOTICE '=== Starting RLS Tests ===';
    RAISE NOTICE 'Marker 1: %', marker1;
    RAISE NOTICE 'Marker 2: %', marker2;
    RAISE NOTICE '';

    -- Test 1: Insert data with marker1
    RAISE NOTICE 'Test 1: Inserting data with marker1...';
    PERFORM set_config('app.current_marker', marker1::text, false);
    
    INSERT INTO subscribers (uuid, email, name, rls_marker)
    VALUES (gen_random_uuid(), 'test1@example.com', 'Test User 1', marker1)
    RETURNING id INTO test_sub_id1;
    
    INSERT INTO lists (uuid, name, type, rls_marker)
    VALUES (gen_random_uuid(), 'Test List 1', 'private', marker1)
    RETURNING id INTO test_list_id1;
    
    RAISE NOTICE 'Created subscriber % and list % with marker1', test_sub_id1, test_list_id1;

    -- Test 2: Insert data with marker2
    RAISE NOTICE '';
    RAISE NOTICE 'Test 2: Inserting data with marker2...';
    PERFORM set_config('app.current_marker', marker2::text, false);
    
    INSERT INTO subscribers (uuid, email, name, rls_marker)
    VALUES (gen_random_uuid(), 'test2@example.com', 'Test User 2', marker2)
    RETURNING id INTO test_sub_id2;
    
    INSERT INTO lists (uuid, name, type, rls_marker)
    VALUES (gen_random_uuid(), 'Test List 2', 'private', marker2)
    RETURNING id INTO test_list_id2;
    
    RAISE NOTICE 'Created subscriber % and list % with marker2', test_sub_id2, test_list_id2;

    -- Test 3: Query with marker1 (should only see marker1 data)
    RAISE NOTICE '';
    RAISE NOTICE 'Test 3: Querying with marker1 session...';
    PERFORM set_config('app.current_marker', marker1::text, false);
    
    IF EXISTS (SELECT 1 FROM subscribers WHERE id = test_sub_id1) THEN
        RAISE NOTICE '  ✓ Can see subscriber %', test_sub_id1;
    ELSE
        RAISE WARNING '  ✗ Cannot see subscriber % (FAIL)', test_sub_id1;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM subscribers WHERE id = test_sub_id2) THEN
        RAISE NOTICE '  ✓ Cannot see subscriber % (correct isolation)', test_sub_id2;
    ELSE
        RAISE WARNING '  ✗ Can see subscriber % (ISOLATION BREACH!)', test_sub_id2;
    END IF;

    -- Test 4: Query with marker2 (should only see marker2 data)
    RAISE NOTICE '';
    RAISE NOTICE 'Test 4: Querying with marker2 session...';
    PERFORM set_config('app.current_marker', marker2::text, false);
    
    IF EXISTS (SELECT 1 FROM subscribers WHERE id = test_sub_id2) THEN
        RAISE NOTICE '  ✓ Can see subscriber %', test_sub_id2;
    ELSE
        RAISE WARNING '  ✗ Cannot see subscriber % (FAIL)', test_sub_id2;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM subscribers WHERE id = test_sub_id1) THEN
        RAISE NOTICE '  ✓ Cannot see subscriber % (correct isolation)', test_sub_id1;
    ELSE
        RAISE WARNING '  ✗ Can see subscriber % (ISOLATION BREACH!)', test_sub_id1;
    END IF;

    -- Test 5: Query with no marker (should see NULL marker data only)
    RAISE NOTICE '';
    RAISE NOTICE 'Test 5: Querying with no session marker...';
    PERFORM set_config('app.current_marker', '', false);
    
    IF NOT EXISTS (SELECT 1 FROM subscribers WHERE id IN (test_sub_id1, test_sub_id2)) THEN
        RAISE NOTICE '  ✓ Cannot see marked subscribers (correct isolation)';
    ELSE
        RAISE WARNING '  ✗ Can see marked subscribers without session marker (FAIL)';
    END IF;

    -- Test 6: Cross-table isolation (subscriber_lists)
    RAISE NOTICE '';
    RAISE NOTICE 'Test 6: Testing junction table isolation...';
    PERFORM set_config('app.current_marker', marker1::text, false);
    
    INSERT INTO subscriber_lists (subscriber_id, list_id, rls_marker, status)
    VALUES (test_sub_id1, test_list_id1, marker1, 'confirmed');
    
    IF EXISTS (SELECT 1 FROM subscriber_lists WHERE subscriber_id = test_sub_id1) THEN
        RAISE NOTICE '  ✓ Can see own junction record';
    ELSE
        RAISE WARNING '  ✗ Cannot see own junction record (FAIL)';
    END IF;
    
    -- Switch to marker2 and try to see marker1 junction
    PERFORM set_config('app.current_marker', marker2::text, false);
    
    IF NOT EXISTS (SELECT 1 FROM subscriber_lists WHERE subscriber_id = test_sub_id1) THEN
        RAISE NOTICE '  ✓ Cannot see other tenant junction record (correct isolation)';
    ELSE
        RAISE WARNING '  ✗ Can see other tenant junction record (ISOLATION BREACH!)';
    END IF;

    -- Cleanup
    RAISE NOTICE '';
    RAISE NOTICE 'Cleaning up test data...';
    PERFORM set_config('app.current_marker', marker1::text, false);
    DELETE FROM subscribers WHERE id = test_sub_id1;
    DELETE FROM lists WHERE id = test_list_id1;
    
    PERFORM set_config('app.current_marker', marker2::text, false);
    DELETE FROM subscribers WHERE id = test_sub_id2;
    DELETE FROM lists WHERE id = test_list_id2;

    RAISE NOTICE '';
    RAISE NOTICE '=== RLS Tests Complete ===';
    RAISE NOTICE 'Review the output above for any WARNINGS or FAIL messages.';
    RAISE NOTICE 'All checks should show ✓ for proper RLS operation.';
END $$;
