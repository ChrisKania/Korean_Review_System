-- Korean Learning System Database Schema
-- Created: 2025-10-17

-- Drop tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS session_stats;
DROP TABLE IF EXISTS user_progress;
DROP TABLE IF EXISTS vocabulary;
DROP TABLE IF EXISTS lessons;

-- Lessons table: stores lesson metadata
CREATE TABLE lessons (
    id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    week INT NOT NULL,
    phase INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vocabulary table: stores all words/phrases
CREATE TABLE vocabulary (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lesson_id INT NOT NULL,
    korean VARCHAR(200) NOT NULL,
    romanization VARCHAR(200) NOT NULL,
    meaning VARCHAR(300) NOT NULL,
    category VARCHAR(50),
    hint TEXT,
    example_sentence TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    INDEX idx_lesson (lesson_id),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User progress table: tracks learning progress per word per device
CREATE TABLE user_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(100) NOT NULL,
    word_id INT NOT NULL,
    correct_count INT DEFAULT 0,
    total_attempts INT DEFAULT 0,
    mastered BOOLEAN DEFAULT FALSE,
    last_reviewed TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (word_id) REFERENCES vocabulary(id) ON DELETE CASCADE,
    UNIQUE KEY unique_device_word (device_id, word_id),
    INDEX idx_device (device_id),
    INDEX idx_mastered (mastered),
    INDEX idx_last_reviewed (last_reviewed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Session stats table: daily study statistics
CREATE TABLE session_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(100) NOT NULL,
    study_date DATE NOT NULL,
    cards_reviewed INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    accuracy DECIMAL(5,2) DEFAULT 0,
    study_time_minutes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_device_date (device_id, study_date),
    INDEX idx_device (device_id),
    INDEX idx_date (study_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
