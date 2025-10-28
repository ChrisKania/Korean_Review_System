<?php
/**
 * Korean Learning System - Progress API
 * WITH SPACED REPETITION SCHEDULING
 * 
 * Handles user progress tracking with intelligent review scheduling
 */

require_once 'config.php';

// Get database connection
$pdo = getDBConnection();

// Get device ID from request
$deviceId = getDeviceId();

// Validate device ID
if (!validateDeviceId($deviceId)) {
    sendResponse(false, 'Invalid or missing device ID');
    exit;
}

// ============================================================================
// GET REQUESTS - Retrieve progress data
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $action = $_GET['action'] ?? 'get_progress';
    
    // ACTION: Get user progress
    if ($action === 'get_progress') {
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    word_id,
                    correct_count,
                    total_attempts,
                    mastered,
                    last_reviewed,
                    next_review_date,
                    review_interval_days,
                    created_at,
                    updated_at
                FROM user_progress
                WHERE device_id = :device_id
                ORDER BY updated_at DESC
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            sendResponse(true, 'Progress retrieved successfully', $progress);
            
        } catch (PDOException $e) {
            error_log("Get progress error: " . $e->getMessage());
            sendResponse(false, 'Database error: ' . $e->getMessage());
        }
        exit;
    }
    
    // ACTION: Get cards due for review today (NON-MASTERED ONLY)
    if ($action === 'due_cards') {
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    up.word_id,
                    up.correct_count,
                    up.total_attempts,
                    up.next_review_date,
                    up.review_interval_days,
                    v.korean,
                    v.romanization,
                    v.meaning,
                    v.category,
                    v.hint,
                    l.title as lesson_title
                FROM user_progress up
                JOIN vocabulary v ON up.word_id = v.id
                JOIN lessons l ON v.lesson_id = l.id
                WHERE up.device_id = :device_id
                AND up.mastered = 0
                AND (up.next_review_date IS NULL OR up.next_review_date <= CURDATE())
                ORDER BY 
                    up.next_review_date ASC,
                    up.total_attempts ASC
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $dueCards = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            sendResponse(true, count($dueCards) . ' cards due for review', $dueCards);
            
        } catch (PDOException $e) {
            error_log("Get due cards error: " . $e->getMessage());
            sendResponse(false, 'Database error: ' . $e->getMessage());
        }
        exit;
    }
    
    // ACTION: Get statistics summary
    if ($action === 'stats') {
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    COUNT(DISTINCT word_id) as total_words,
                    SUM(CASE WHEN total_attempts > 0 THEN 1 ELSE 0 END) as words_studied,
                    SUM(CASE WHEN mastered = 1 THEN 1 ELSE 0 END) as words_mastered,
                    SUM(correct_count) as total_correct,
                    SUM(total_attempts) as total_attempts,
                    MAX(last_reviewed) as last_review_date,
                    SUM(CASE WHEN next_review_date <= CURDATE() AND mastered = 0 THEN 1 ELSE 0 END) as due_today,
                    SUM(CASE WHEN next_review_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND mastered = 0 THEN 1 ELSE 0 END) as due_tomorrow,
                    SUM(CASE WHEN next_review_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) AND mastered = 0 THEN 1 ELSE 0 END) as due_this_week,
                    AVG(CASE WHEN mastered = 0 THEN review_interval_days END) as avg_interval
                FROM user_progress
                WHERE device_id = :device_id
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $stats = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Calculate accuracy
            $accuracy = $stats['total_attempts'] > 0 
                ? round(($stats['total_correct'] / $stats['total_attempts']) * 100, 1)
                : 0;
            
            $stats['accuracy'] = $accuracy;
            $stats['avg_interval'] = round($stats['avg_interval'], 1);
            
            sendResponse(true, 'Statistics retrieved successfully', $stats);
            
        } catch (PDOException $e) {
            error_log("Get stats error: " . $e->getMessage());
            sendResponse(false, 'Database error: ' . $e->getMessage());
        }
        exit;
    }
    
    // ACTION: Get review schedule (calendar view)
    if ($action === 'schedule') {
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    next_review_date as date,
                    COUNT(*) as total_cards,
                    SUM(CASE WHEN mastered = 0 THEN 1 ELSE 0 END) as active_cards,
                    SUM(CASE WHEN mastered = 1 THEN 1 ELSE 0 END) as mastered_cards
                FROM user_progress
                WHERE device_id = :device_id
                  AND next_review_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
                GROUP BY next_review_date
                ORDER BY next_review_date
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $schedule = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            sendResponse(true, 'Review schedule retrieved', $schedule);
            
        } catch (PDOException $e) {
            error_log("Get schedule error: " . $e->getMessage());
            sendResponse(false, 'Database error: ' . $e->getMessage());
        }
        exit;
    }
    
    // ACTION: Get session statistics (daily summaries)
    if ($action === 'session_stats') {
        try {
            $stmt = $pdo->prepare("
                SELECT 
                    study_date,
                    cards_reviewed,
                    accuracy,
                    created_at
                FROM session_stats
                WHERE device_id = :device_id
                ORDER BY study_date DESC
                LIMIT 30
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            sendResponse(true, 'Session stats retrieved successfully', $stats);
            
        } catch (PDOException $e) {
            error_log("Get session stats error: " . $e->getMessage());
            sendResponse(false, 'Database error: ' . $e->getMessage());
        }
        exit;
    }
    
    // Unknown action
    sendResponse(false, 'Unknown action: ' . $action);
    exit;
}

// ============================================================================
// POST REQUESTS - Update single word progress WITH SCHEDULING
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        sendResponse(false, 'Invalid JSON data');
        exit;
    }
    
    // Validate required fields
    if (!isset($data['word_id']) || !isset($data['is_correct'])) {
        sendResponse(false, 'Missing required fields: word_id and is_correct');
        exit;
    }
    
    $wordId = (int)$data['word_id'];
    $isCorrect = (bool)$data['is_correct'];
    
    try {
        // Check if progress exists for this word
        $stmt = $pdo->prepare("
            SELECT 
                id, 
                correct_count, 
                total_attempts, 
                mastered,
                review_interval_days
            FROM user_progress
            WHERE device_id = :device_id AND word_id = :word_id
        ");
        
        $stmt->execute([
            ':device_id' => $deviceId,
            ':word_id' => $wordId
        ]);
        
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existing) {
            // UPDATE existing progress
            $newCorrect = $existing['correct_count'] + ($isCorrect ? 1 : 0);
            $newTotal = $existing['total_attempts'] + 1;
            
            // Calculate if mastered (80% accuracy after 3+ attempts)
            $isMastered = ($newTotal >= 3 && ($newCorrect / $newTotal) >= 0.8) ? 1 : 0;
            
            // CALCULATE NEXT REVIEW DATE using spaced repetition
            $currentInterval = $existing['review_interval_days'] ?? 0;
            $newInterval = calculateNextReviewInterval($currentInterval, $isCorrect, $newTotal);
            $nextReviewDate = calculateNextReviewDate($newInterval);
            
            $stmt = $pdo->prepare("
                UPDATE user_progress
                SET 
                    correct_count = :correct_count,
                    total_attempts = :total_attempts,
                    mastered = :mastered,
                    last_reviewed = NOW(),
                    next_review_date = :next_review_date,
                    review_interval_days = :review_interval_days,
                    updated_at = NOW()
                WHERE device_id = :device_id AND word_id = :word_id
            ");
            
            $stmt->execute([
                ':correct_count' => $newCorrect,
                ':total_attempts' => $newTotal,
                ':mastered' => $isMastered,
                ':next_review_date' => $nextReviewDate,
                ':review_interval_days' => $newInterval,
                ':device_id' => $deviceId,
                ':word_id' => $wordId
            ]);
            
            $result = [
                'word_id' => $wordId,
                'correct_count' => $newCorrect,
                'total_attempts' => $newTotal,
                'mastered' => (bool)$isMastered,
                'next_review_date' => $nextReviewDate,
                'review_interval_days' => $newInterval
            ];
            
        } else {
            // INSERT new progress
            $correctCount = $isCorrect ? 1 : 0;
            $totalAttempts = 1;
            $isMastered = 0; // Can't be mastered on first attempt
            
            // First review: 1 day if correct, 0 (today) if difficult
            $newInterval = calculateNextReviewInterval(0, $isCorrect, 1);
            $nextReviewDate = calculateNextReviewDate($newInterval);
            
            $stmt = $pdo->prepare("
                INSERT INTO user_progress 
                    (device_id, word_id, correct_count, total_attempts, mastered, 
                     last_reviewed, next_review_date, review_interval_days, created_at, updated_at)
                VALUES 
                    (:device_id, :word_id, :correct_count, :total_attempts, :mastered, 
                     NOW(), :next_review_date, :review_interval_days, NOW(), NOW())
            ");
            
            $stmt->execute([
                ':device_id' => $deviceId,
                ':word_id' => $wordId,
                ':correct_count' => $correctCount,
                ':total_attempts' => $totalAttempts,
                ':mastered' => $isMastered,
                ':next_review_date' => $nextReviewDate,
                ':review_interval_days' => $newInterval
            ]);
            
            $result = [
                'word_id' => $wordId,
                'correct_count' => $correctCount,
                'total_attempts' => $totalAttempts,
                'mastered' => false,
                'next_review_date' => $nextReviewDate,
                'review_interval_days' => $newInterval
            ];
        }
        
        // Update session stats (daily summary)
        updateSessionStats($pdo, $deviceId);
        
        sendResponse(true, 'Progress updated successfully', $result);
        
    } catch (PDOException $e) {
        error_log("Update progress error: " . $e->getMessage());
        sendResponse(false, 'Database error: ' . $e->getMessage());
    }
    exit;
}

// ============================================================================
// PUT REQUESTS - Batch update (for import)
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Get JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data || !isset($data['progress']) || !is_array($data['progress'])) {
        sendResponse(false, 'Invalid data format. Expected: {progress: [...]}');
        exit;
    }
    
    try {
        $pdo->beginTransaction();
        
        $imported = 0;
        $errors = 0;
        
        foreach ($data['progress'] as $wordId => $stats) {
            try {
                // Validate data
                if (!is_numeric($wordId) || !isset($stats['correct']) || !isset($stats['total'])) {
                    $errors++;
                    continue;
                }
                
                $correctCount = (int)$stats['correct'];
                $totalAttempts = (int)$stats['total'];
                $isMastered = isset($stats['mastered']) ? (bool)$stats['mastered'] : false;
                $lastReview = isset($stats['lastReview']) ? date('Y-m-d H:i:s', $stats['lastReview'] / 1000) : null;
                
                // Calculate review schedule if not provided
                $reviewInterval = isset($stats['review_interval_days']) ? (int)$stats['review_interval_days'] : 
                    calculateNextReviewInterval(0, $correctCount / max($totalAttempts, 1) > 0.5, $totalAttempts);
                
                $nextReviewDate = isset($stats['next_review_date']) ? $stats['next_review_date'] : 
                    calculateNextReviewDate($reviewInterval);
                
                // Insert or update
                $stmt = $pdo->prepare("
                    INSERT INTO user_progress 
                        (device_id, word_id, correct_count, total_attempts, mastered, 
                         last_reviewed, next_review_date, review_interval_days, created_at, updated_at)
                    VALUES 
                        (:device_id, :word_id, :correct_count, :total_attempts, :mastered, 
                         :last_reviewed, :next_review_date, :review_interval_days, NOW(), NOW())
                    ON DUPLICATE KEY UPDATE
                        correct_count = VALUES(correct_count),
                        total_attempts = VALUES(total_attempts),
                        mastered = VALUES(mastered),
                        last_reviewed = VALUES(last_reviewed),
                        next_review_date = VALUES(next_review_date),
                        review_interval_days = VALUES(review_interval_days),
                        updated_at = NOW()
                ");
                
                $stmt->execute([
                    ':device_id' => $deviceId,
                    ':word_id' => (int)$wordId,
                    ':correct_count' => $correctCount,
                    ':total_attempts' => $totalAttempts,
                    ':mastered' => $isMastered ? 1 : 0,
                    ':last_reviewed' => $lastReview,
                    ':next_review_date' => $nextReviewDate,
                    ':review_interval_days' => $reviewInterval
                ]);
                
                $imported++;
                
            } catch (PDOException $e) {
                error_log("Import word $wordId error: " . $e->getMessage());
                $errors++;
            }
        }
        
        $pdo->commit();
        
        sendResponse(true, "Import completed: $imported imported, $errors errors", [
            'imported' => $imported,
            'errors' => $errors
        ]);
        
    } catch (PDOException $e) {
        $pdo->rollBack();
        error_log("Batch import error: " . $e->getMessage());
        sendResponse(false, 'Import failed: ' . $e->getMessage());
    }
    exit;
}

// ============================================================================
// DELETE REQUESTS - Reset progress (optional)
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    try {
        $stmt = $pdo->prepare("
            DELETE FROM user_progress
            WHERE device_id = :device_id
        ");
        
        $stmt->execute([':device_id' => $deviceId]);
        $deleted = $stmt->rowCount();
        
        sendResponse(true, "Progress reset: $deleted records deleted", [
            'deleted' => $deleted
        ]);
        
    } catch (PDOException $e) {
        error_log("Delete progress error: " . $e->getMessage());
        sendResponse(false, 'Database error: ' . $e->getMessage());
    }
    exit;
}

// ============================================================================
// HELPER FUNCTIONS - SPACED REPETITION LOGIC
// ============================================================================

/**
 * Calculate next review interval based on performance
 * Uses simplified SM-2 algorithm
 * 
 * @param int $currentInterval Current interval in days
 * @param bool $isCorrect Whether the answer was correct
 * @param int $totalAttempts Total number of reviews for this card
 * @return int New interval in days
 */
function calculateNextReviewInterval($currentInterval, $isCorrect, $totalAttempts) {
    // First review
    if ($totalAttempts == 0 || $totalAttempts == 1) {
        return $isCorrect ? 1 : 0; // 1 day if correct, review again today if difficult
    }
    
    // Second review
    if ($totalAttempts == 2) {
        return $isCorrect ? 3 : 1; // 3 days if correct, 1 day if difficult
    }
    
    // Third review
    if ($totalAttempts == 3) {
        return $isCorrect ? 7 : 1; // 1 week if correct, 1 day if difficult
    }
    
    // Fourth+ reviews
    if ($isCorrect) {
        // Double the interval, cap at 180 days (6 months)
        $newInterval = $currentInterval * 2;
        
        // Ensure minimum interval of 7 days for established cards
        if ($newInterval < 7) {
            $newInterval = 7;
        }
        
        // Cap at 180 days maximum
        return min($newInterval, 180);
    } else {
        // Reset to 1 day on difficulty
        return 1;
    }
}

/**
 * Calculate the actual next review date
 * 
 * @param int $intervalDays Number of days from now
 * @return string Date in Y-m-d format
 */
function calculateNextReviewDate($intervalDays) {
    return date('Y-m-d', strtotime("+{$intervalDays} days"));
}

/**
 * Update session statistics (daily summary)
 * Called after each progress update to maintain daily stats
 */
function updateSessionStats($pdo, $deviceId) {
    try {
        $today = date('Y-m-d');
        
        // Calculate today's stats from all reviews made today
        $stmt = $pdo->prepare("
            SELECT 
                COUNT(DISTINCT word_id) as unique_cards,
                SUM(correct_count) as total_correct,
                SUM(total_attempts) as total_attempts
            FROM user_progress
            WHERE device_id = :device_id 
            AND DATE(updated_at) = :today
        ");
        
        $stmt->execute([
            ':device_id' => $deviceId,
            ':today' => $today
        ]);
        
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $cardsReviewed = (int)($stats['unique_cards'] ?? 0);
        $totalCorrect = (int)($stats['total_correct'] ?? 0);
        $totalAttempts = (int)($stats['total_attempts'] ?? 0);
        
        if ($cardsReviewed === 0) {
            return; // No cards reviewed today yet
        }
        
        $accuracy = $totalAttempts > 0 
            ? round(($totalCorrect / $totalAttempts) * 100, 1)
            : 0;
        
        // Upsert today's session stats
        $stmt = $pdo->prepare("
            INSERT INTO session_stats 
                (device_id, study_date, cards_reviewed, accuracy, created_at, updated_at)
            VALUES 
                (:device_id, :study_date, :cards_reviewed, :accuracy, NOW(), NOW())
            ON DUPLICATE KEY UPDATE
                cards_reviewed = :cards_reviewed_update,
                accuracy = :accuracy_update,
                updated_at = NOW()
        ");
        
        $stmt->execute([
            ':device_id' => $deviceId,
            ':study_date' => $today,
            ':cards_reviewed' => $cardsReviewed,
            ':accuracy' => $accuracy,
            ':cards_reviewed_update' => $cardsReviewed,
            ':accuracy_update' => $accuracy
        ]);
        
        return true;
        
    } catch (PDOException $e) {
        error_log("Session stats update failed: " . $e->getMessage());
        return false;
    }
}

// ============================================================================
// INVALID METHOD
// ============================================================================

sendResponse(false, 'Invalid request method: ' . $_SERVER['REQUEST_METHOD']);
