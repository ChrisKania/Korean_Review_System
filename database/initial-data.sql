-- Initial Data: Lessons 1-8 Vocabulary
-- Korean Learning System

-- Insert Lessons
INSERT INTO lessons (id, title, week, phase, description) VALUES
(1, 'Greetings & Introduction', 1, 1, 'Hello, I am... (Basic introductions)'),
(2, 'Where Are You From?', 1, 1, 'Countries, nationalities'),
(3, 'Polite Expressions', 1, 1, 'Nice to meet you (Polite expressions)'),
(4, 'Yes/No and Basic Responses', 1, 1, 'Basic responses'),
(5, 'Week 1 Review & Consolidation', 1, 1, 'Review of Week 1'),
(6, 'What Do You Do?', 2, 1, 'Occupations and hobbies'),
(7, 'Family Members', 2, 1, 'Family vocabulary'),
(8, 'Age and Numbers', 2, 1, 'Numbers 1-100 and age');

-- Insert Vocabulary for Lesson 1: Greetings & Introduction
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(1, '안녕하세요', 'annyeonghaseyo', 'Hello', 'greeting'),
(1, '저는', 'jeoneun', 'I am', 'grammar'),
(1, '입니다', 'imnida', 'am/is/are', 'grammar'),
(1, '감사합니다', 'gamsahamnida', 'Thank you', 'greeting');

-- Insert Vocabulary for Lesson 2: Where Are You From?
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(2, '어디에서 왔어요?', 'eodieseo wasseoyo?', 'Where are you from?', 'question'),
(2, '영국', 'yeongguk', 'United Kingdom', 'country'),
(2, '한국', 'hanguk', 'Korea', 'country'),
(2, '에서', 'eseo', 'from (particle)', 'grammar'),
(2, '왔어요', 'wasseoyo', 'came', 'verb');

-- Insert Vocabulary for Lesson 3: Polite Expressions
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(3, '만나서 반갑습니다', 'mannaseo bangapseumnida', 'Nice to meet you', 'greeting'),
(3, '잘 부탁합니다', 'jal butakamnida', 'Please treat me well', 'greeting'),
(3, '네', 'ne', 'Yes', 'response'),
(3, '아니요', 'aniyo', 'No', 'response');

-- Insert Vocabulary for Lesson 4: Yes/No and Basic Responses
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(4, '괜찮아요', 'gwaenchanayo', 'It is okay', 'response'),
(4, '사람', 'saram', 'person', 'noun'),
(4, '학생', 'haksaeng', 'student', 'noun');

-- Insert Vocabulary for Lesson 6: What Do You Do? (Jobs & Occupations)
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(6, '뭐 해요?', 'mwo haeyo?', 'What do you do?', 'question'),
(6, 'VFX 아티스트', 'VFX atiseuteu', 'VFX artist', 'occupation'),
(6, '예요', 'yeyo', 'am/is/are (casual)', 'grammar');

-- Insert Vocabulary for Lesson 7: Family Members
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(7, '가족', 'gajok', 'family', 'noun'),
(7, '엄마', 'eomma', 'mom', 'family'),
(7, '아빠', 'appa', 'dad', 'family'),
(7, '형제', 'hyeongje', 'siblings', 'family'),
(7, '오빠', 'oppa', 'older brother (by female)', 'family'),
(7, '언니', 'eonni', 'older sister (by female)', 'family'),
(7, '동생', 'dongsaeng', 'younger sibling', 'family'),
(7, '있어요', 'isseoyo', 'have/there is', 'verb'),
(7, '없어요', 'eopseoyo', 'do not have/there is not', 'verb'),
(7, '몇', 'myeot', 'how many', 'question'),
(7, '명', 'myeong', 'counter for people', 'counter');

-- Insert Vocabulary for Lesson 8: Age and Numbers
INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category) VALUES
(8, '하나', 'hana', 'one', 'number'),
(8, '둘', 'dul', 'two', 'number'),
(8, '셋', 'set', 'three', 'number'),
(8, '넷', 'net', 'four', 'number'),
(8, '다섯', 'daseot', 'five', 'number'),
(8, '여섯', 'yeoseot', 'six', 'number'),
(8, '일곱', 'ilgop', 'seven', 'number'),
(8, '여덟', 'yeodeol', 'eight', 'number'),
(8, '아홉', 'ahop', 'nine', 'number'),
(8, '열', 'yeol', 'ten', 'number'),
(8, '스물', 'seumul', 'twenty', 'number'),
(8, '서른', 'seoreun', 'thirty', 'number'),
(8, '마흔', 'maheun', 'forty', 'number'),
(8, '쉰', 'swin', 'fifty', 'number'),
(8, '예순', 'yesun', 'sixty', 'number'),
(8, '일흔', 'ilheun', 'seventy', 'number'),
(8, '여든', 'yeodeun', 'eighty', 'number'),
(8, '아흔', 'aheun', 'ninety', 'number'),
(8, '개', 'gae', 'counter for things', 'counter'),
(8, '몇 살이에요?', 'myeot salieyo?', 'How old are you?', 'question'),
(8, '살', 'sal', 'years old (age counter)', 'counter');

-- Verify data
SELECT 'Lessons inserted:' as message, COUNT(*) as count FROM lessons;
SELECT 'Vocabulary inserted:' as message, COUNT(*) as count FROM vocabulary;
SELECT 'Words per lesson:' as message, lesson_id, COUNT(*) as word_count 
FROM vocabulary 
GROUP BY lesson_id 
ORDER BY lesson_id;
