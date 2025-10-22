<?php
/**
 * Lessons API Endpoint
 * Handles fetching lessons and vocabulary data
 */

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = getDBConnection();

switch ($method) {
    case 'GET':
        handleGet($pdo);
        break;
    default:
        sendResponse(false, null, 'Method not allowed', 405);
}

/**
 * Handle GET requests
 */
function handleGet($pdo) {
    // Get all lessons
    if (!isset($_GET['action']) || $_GET['action'] === 'list') {
        getAllLessons($pdo);
    }
    // Get specific lesson with vocabulary
    elseif ($_GET['action'] === 'detail' && isset($_GET['lesson_id'])) {
        getLessonDetail($pdo, $_GET['lesson_id']);
    }
    // Get all vocabulary (for flashcards)
    elseif ($_GET['action'] === 'vocabulary') {
        getAllVocabulary($pdo);
    }
    // Get vocabulary by lesson
    elseif ($_GET['action'] === 'vocabulary_by_lesson' && isset($_GET['lesson_id'])) {
        getVocabularyByLesson($pdo, $_GET['lesson_id']);
    }
    else {
        sendResponse(false, null, 'Invalid action or missing parameters', 400);
    }
}

/**
 * Get all lessons
 */
function getAllLessons($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT 
                l.id,
                l.title,
                l.week,
                l.phase,
                l.description,
                COUNT(v.id) as word_count
            FROM lessons l
            LEFT JOIN vocabulary v ON l.id = v.lesson_id
            GROUP BY l.id, l.title, l.week, l.phase, l.description
            ORDER BY l.id
        ");
        
        $lessons = $stmt->fetchAll();
        
        sendResponse(true, 'Lessons retrieved successfully', $lessons );
    } catch (PDOException $e) {
        sendResponse(false, null, 'Failed to retrieve lessons: ' . $e->getMessage(), 500);
    }
}

/**
 * Get lesson detail with vocabulary
 */
function getLessonDetail($pdo, $lessonId) {
    try {
        // Get lesson info
        $stmt = $pdo->prepare("SELECT * FROM lessons WHERE id = ?");
        $stmt->execute([$lessonId]);
        $lesson = $stmt->fetch();
        
        if (!$lesson) {
            sendResponse(false, null, 'Lesson not found', 404);
            return;
        }
        
        // Get vocabulary for this lesson
        $stmt = $pdo->prepare("
            SELECT 
                id,
                korean,
                romanization,
                meaning,
                category,
                hint,
                example_sentence
            FROM vocabulary
            WHERE lesson_id = ?
            ORDER BY id
        ");
        $stmt->execute([$lessonId]);
        $vocabulary = $stmt->fetchAll();
        
        $lesson['vocabulary'] = $vocabulary;
        $lesson['word_count'] = count($vocabulary);
        
        sendResponse(true, 'Lesson detail retrieved successfully', $lesson);
    } catch (PDOException $e) {
        sendResponse(false, null, 'Failed to retrieve lesson: ' . $e->getMessage(), 500);
    }
}

/**
 * Get all vocabulary (for flashcard mode)
 */
function getAllVocabulary($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT 
                v.id,
                v.lesson_id,
                v.korean,
                v.romanization,
                v.meaning,
                v.category,
                v.hint,
                l.title as lesson_title
            FROM vocabulary v
            JOIN lessons l ON v.lesson_id = l.id
            ORDER BY v.lesson_id, v.id
        ");
        
        $vocabulary = $stmt->fetchAll();
        
        sendResponse(true, 'Vocabulary retrieved successfully', $vocabulary);
    } catch (PDOException $e) {
        sendResponse(false, null, 'Failed to retrieve vocabulary: ' . $e->getMessage(), 500);
    }
}

/**
 * Get vocabulary by specific lesson
 */
function getVocabularyByLesson($pdo, $lessonId) {
    try {
        $stmt = $pdo->prepare("
            SELECT 
                v.id,
                v.korean,
                v.romanization,
                v.meaning,
                v.category,
                v.hint,
                v.example_sentence
            FROM vocabulary v
            WHERE v.lesson_id = ?
            ORDER BY v.id
        ");
        $stmt->execute([$lessonId]);
        $vocabulary = $stmt->fetchAll();
        
        sendResponse(true, 'Vocabulary retrieved successfully' , $vocabulary);
    } catch (PDOException $e) {
        sendResponse(false, null, 'Failed to retrieve vocabulary: ' . $e->getMessage(), 500);
    }
}
