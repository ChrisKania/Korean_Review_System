-- ============================================================================
-- SPACED REPETITION DATABASE MIGRATION (FIXED VERSION)
-- Korean Learning System - Add Smart Scheduling
-- ============================================================================
-- 
-- This version handles cases where indexes already exist
--
-- INSTRUCTIONS:
-- 1. Backup your database first! (Export via phpMyAdmin)
-- 2. Run this script via phpMyAdmin SQL tab
-- 3. Verify with the test queries at the bottom
--
-- ============================================================================

-- Add new columns to user_progress table (only if they don't exist)
SET @dbname = DATABASE();
SET @tablename = 'user_progress';
SET @columnname1 = 'next_review_date';
SET @columnname2 = 'review_interval_days';

-- Check and add next_review_date column
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname1)
  ) > 0,
  'SELECT 1', -- Column exists, do nothing
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN next_review_date DATE NULL AFTER last_reviewed')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Check and add review_interval_days column
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname2)
  ) > 0,
  'SELECT 1', -- Column exists, do nothing
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN review_interval_days INT DEFAULT 0 AFTER next_review_date')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add indexes (only if they don't exist)
-- Note: We'll ignore errors if indexes already exist
SET @index1 = 'idx_next_review';
SET @index2 = 'idx_mastered';

-- Try to create idx_next_review (ignore if exists)
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (index_name = @index1)
  ) > 0,
  'SELECT 1', -- Index exists
  CONCAT('CREATE INDEX idx_next_review ON user_progress(device_id, next_review_date)')
));
PREPARE createIndexIfNotExists FROM @preparedStatement;
EXECUTE createIndexIfNotExists;
DEALLOCATE PREPARE createIndexIfNotExists;

-- Try to create idx_mastered (ignore if exists)
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (index_name = @index2)
  ) > 0,
  'SELECT 1', -- Index exists
  CONCAT('CREATE INDEX idx_mastered ON user_progress(device_id, mastered)')
));
PREPARE createIndexIfNotExists FROM @preparedStatement;
EXECUTE createIndexIfNotExists;
DEALLOCATE PREPARE createIndexIfNotExists;

SELECT '✅ Columns and indexes checked/added successfully' as status;

-- ============================================================================
-- INITIALIZE EXISTING DATA (only update NULL values)
-- ============================================================================

-- New cards (never reviewed) - review today
UPDATE user_progress 
SET next_review_date = CURDATE(),
    review_interval_days = 0
WHERE next_review_date IS NULL 
  AND total_attempts = 0;

-- Cards reviewed once - review in 1 day
UPDATE user_progress 
SET next_review_date = DATE_ADD(IFNULL(last_reviewed, NOW()), INTERVAL 1 DAY),
    review_interval_days = 1
WHERE next_review_date IS NULL 
  AND total_attempts = 1;

-- Cards reviewed twice - review in 3 days
UPDATE user_progress 
SET next_review_date = DATE_ADD(IFNULL(last_reviewed, NOW()), INTERVAL 3 DAY),
    review_interval_days = 3
WHERE next_review_date IS NULL 
  AND total_attempts = 2;

-- Cards reviewed 3+ times - review in 7 days
UPDATE user_progress 
SET next_review_date = DATE_ADD(IFNULL(last_reviewed, NOW()), INTERVAL 7 DAY),
    review_interval_days = 7
WHERE next_review_date IS NULL 
  AND total_attempts >= 3
  AND mastered = 0;

-- Mastered cards - review in 30 days (light maintenance)
UPDATE user_progress 
SET next_review_date = DATE_ADD(IFNULL(last_reviewed, NOW()), INTERVAL 30 DAY),
    review_interval_days = 30
WHERE mastered = 1
  AND next_review_date IS NULL;

SELECT '✅ Existing data initialized successfully' as status;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check that columns were added
SELECT 'Checking columns...' as status;
DESCRIBE user_progress;

-- Show distribution of intervals
SELECT 
    '📊 Distribution by Status' as report_type,
    CASE 
        WHEN total_attempts = 0 THEN '0 - New'
        WHEN total_attempts = 1 THEN '1 - First review'
        WHEN total_attempts = 2 THEN '2 - Second review'
        WHEN total_attempts >= 3 AND mastered = 0 THEN '3+ - Learning'
        WHEN mastered = 1 THEN 'Mastered 🏆'
    END as card_status,
    COUNT(*) as count,
    ROUND(AVG(review_interval_days), 1) as avg_interval_days,
    MIN(next_review_date) as earliest_review,
    MAX(next_review_date) as latest_review
FROM user_progress
GROUP BY card_status
ORDER BY 
    CASE card_status
        WHEN '0 - New' THEN 1
        WHEN '1 - First review' THEN 2
        WHEN '2 - Second review' THEN 3
        WHEN '3+ - Learning' THEN 4
        WHEN 'Mastered 🏆' THEN 5
    END;

-- Show cards due today
SELECT 
    '📅 Due Today' as report_type,
    COUNT(*) as cards_due
FROM user_progress
WHERE next_review_date <= CURDATE()
  AND mastered = 0;

-- Show cards due this week
SELECT 
    '📅 Due This Week' as report_type,
    COUNT(*) as cards_due
FROM user_progress
WHERE next_review_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND mastered = 0;

-- Show upcoming review schedule (next 7 days)
SELECT 
    '📆 Next 7 Days Schedule' as report_type,
    next_review_date as date,
    COUNT(*) as total_cards,
    SUM(CASE WHEN mastered = 0 THEN 1 ELSE 0 END) as active_cards,
    SUM(CASE WHEN mastered = 1 THEN 1 ELSE 0 END) as mastered_cards
FROM user_progress
WHERE next_review_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
GROUP BY next_review_date
ORDER BY next_review_date;

-- ============================================================================
-- FINAL STATUS CHECK
-- ============================================================================

SELECT 
    '✅ MIGRATION COMPLETE' as status,
    'Your database is ready for spaced repetition!' as message,
    'Next step: Update api/progress.php' as next_action;

-- Summary statistics
SELECT 
    '📊 Summary' as report,
    (SELECT COUNT(*) FROM user_progress) as total_cards,
    (SELECT COUNT(*) FROM user_progress WHERE next_review_date <= CURDATE() AND mastered = 0) as due_today,
    (SELECT COUNT(*) FROM user_progress WHERE mastered = 1) as mastered,
    (SELECT ROUND(AVG(review_interval_days), 1) FROM user_progress WHERE mastered = 0) as avg_interval_days;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- 
-- ✅ If all queries ran successfully, you're ready to update your API!
-- ✅ Next step: Update api/progress.php with new scheduling logic
-- ✅ See SPACED-REPETITION-ENHANCEMENT.md for complete guide
--
-- ============================================================================
