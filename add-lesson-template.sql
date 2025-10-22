-- Template for Adding New Lessons
-- Korean Learning System
-- 
-- INSTRUCTIONS:
-- 1. Copy this template
-- 2. Replace the values with your lesson data
-- 3. Update lesson_id in all INSERT statements
-- 4. Import via phpMyAdmin or MySQL command line

-- ======================================
-- LESSON 9 TEMPLATE
-- ======================================

-- Add the lesson metadata
INSERT INTO lessons (id, title, week, phase, description) VALUES
(9, 'Telephone Numbers & Contact Info', 2, 1, 'How to share and ask for contact information');

-- Add vocabulary for the lesson
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category, hint, example_sentence) VALUES
-- Replace these with your actual vocabulary
(9, '전화번호', 'jeonhwabeonho', 'telephone number', 'noun', NULL, '전화번호가 뭐예요?'),
(9, '핸드폰', 'haendeupon', 'cell phone', 'noun', NULL, '핸드폰이 있어요?'),
(9, '이메일', 'imeil', 'email', 'noun', NULL, '이메일 주소를 알려주세요');

-- Verify the insertion
SELECT * FROM lessons WHERE id = 9;
SELECT * FROM vocabulary WHERE lesson_id = 9;

-- ======================================
-- LESSON 10 TEMPLATE
-- ======================================

-- Add the lesson metadata
INSERT INTO lessons (id, title, week, phase, description) VALUES
(10, 'Review & Conversation Practice', 2, 1, 'Week 2 review and consolidation');

-- Note: Review lessons might not have new vocabulary
-- Or they might include commonly confused words

-- ======================================
-- HELPFUL QUERIES
-- ======================================

-- Check total word count by lesson
SELECT 
    l.id,
    l.title,
    COUNT(v.id) as word_count
FROM lessons l
LEFT JOIN vocabulary v ON l.id = v.lesson_id
GROUP BY l.id, l.title
ORDER BY l.id;

-- Find lessons without vocabulary
SELECT l.* 
FROM lessons l
LEFT JOIN vocabulary v ON l.id = v.lesson_id
WHERE v.id IS NULL;

-- Get all categories used
SELECT DISTINCT category 
FROM vocabulary 
ORDER BY category;

-- Count words by category
SELECT category, COUNT(*) as count
FROM vocabulary
GROUP BY category
ORDER BY count DESC;

-- ======================================
-- BULK INSERT TEMPLATE
-- ======================================
-- Use this pattern for adding multiple lessons at once

INSERT INTO lessons (id, title, week, phase, description) VALUES
(11, 'This/That/It', 3, 1, 'Demonstratives'),
(12, 'What is this?', 3, 1, 'Basic questions'),
(13, 'I like/I don\'t like', 3, 1, 'Expressing preferences'),
(14, 'I have/I don\'t have', 3, 1, 'Possession'),
(15, 'Review Week', 3, 1, 'Week 3 consolidation');

-- Then add vocabulary for each lesson
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
-- Lesson 11 words
(11, '이것', 'igeot', 'this', 'demonstrative'),
(11, '그것', 'geugeot', 'that', 'demonstrative'),
(11, '저것', 'jeogeot', 'that (over there)', 'demonstrative'),
-- Lesson 12 words
(12, '이게 뭐예요?', 'ige mwoyeyo?', 'What is this?', 'question'),
(12, '뭐예요?', 'mwoyeyo?', 'What is it?', 'question'),
-- Add more as needed...
;

-- ======================================
-- CATEGORIES TO USE
-- ======================================
-- Keep these consistent for better organization:
-- - 'greeting': Greetings and farewells
-- - 'grammar': Grammar particles and patterns
-- - 'question': Question words and phrases
-- - 'response': Common responses
-- - 'noun': General nouns
-- - 'verb': Action words
-- - 'adjective': Descriptive words
-- - 'number': Numbers (native Korean)
-- - 'sino-number': Numbers (Sino-Korean)
-- - 'counter': Counting words
-- - 'family': Family members
-- - 'occupation': Jobs and professions
-- - 'country': Countries and places
-- - 'food': Food and drink
-- - 'time': Time-related words
-- - 'demonstrative': This, that, etc.
-- - 'direction': Location and direction words

-- ======================================
-- VALIDATION QUERIES
-- ======================================

-- Check for duplicate Korean words
SELECT korean, COUNT(*) as count
FROM vocabulary
GROUP BY korean
HAVING count > 1;

-- Check for missing romanization
SELECT * FROM vocabulary WHERE romanization IS NULL OR romanization = '';

-- Check for missing meanings
SELECT * FROM vocabulary WHERE meaning IS NULL OR meaning = '';

-- Get lesson completion status
SELECT 
    l.id,
    l.title,
    l.week,
    COUNT(v.id) as word_count,
    CASE 
        WHEN COUNT(v.id) = 0 THEN '❌ No vocabulary'
        WHEN COUNT(v.id) < 3 THEN '⚠️  Few words'
        ELSE '✅ Complete'
    END as status
FROM lessons l
LEFT JOIN vocabulary v ON l.id = v.lesson_id
GROUP BY l.id, l.title, l.week
ORDER BY l.id;
