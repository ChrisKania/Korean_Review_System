<?php
/**
 * Korean Learning System - Progress API
 * Handles user progress tracking and statistics
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
                    created_at,
                    updated_at
                FROM user_progress
                WHERE device_id = :device_id
                ORDER BY updated_at DESC
            ");
            
            $stmt->execute([':device_id' => $deviceId]);
            $progress = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // CRITICAL FIX: Return with proper format (3 parameters)
            sendResponse(true, 'Progress retrieved successfully', $progress);
            
        } catch (PDOException $e) {
            error_log("Get progress error: " . $e->getMessage());
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
                    MAX(last_reviewed) as last_review_date
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
            
            sendResponse(true, 'Statistics retrieved successfully', $stats);
            
        } catch (PDOException $e) {
            error_log("Get stats error: " . $e->getMessage());
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
// POST REQUESTS - Update single word progress
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
            SELECT id, correct_count, total_attempts, mastered
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
            
            $stmt = $pdo->prepare("
                UPDATE user_progress
                SET 
                    correct_count = :correct_count,
                    total_attempts = :total_attempts,
                    mastered = :mastered,
                    last_reviewed = NOW(),
                    updated_at = NOW()
                WHERE device_id = :device_id AND word_id = :word_id
            ");
            
            $stmt->execute([
                ':correct_count' => $newCorrect,
                ':total_attempts' => $newTotal,
                ':mastered' => $isMastered,
                ':device_id' => $deviceId,
                ':word_id' => $wordId
            ]);
            
            $result = [
                'word_id' => $wordId,
                'correct_count' => $newCorrect,
                'total_attempts' => $newTotal,
                'mastered' => (bool)$isMastered
            ];
            
        } else {
            // INSERT new progress
            $correctCount = $isCorrect ? 1 : 0;
            $totalAttempts = 1;
            $isMastered = 0; // Can't be mastered on first attempt
            
            $stmt = $pdo->prepare("
                INSERT INTO user_progress 
                    (device_id, word_id, correct_count, total_attempts, mastered, last_reviewed, created_at, updated_at)
                VALUES 
                    (:device_id, :word_id, :correct_count, :total_attempts, :mastered, NOW(), NOW(), NOW())
            ");
            
            $stmt->execute([
                ':device_id' => $deviceId,
                ':word_id' => $wordId,
                ':correct_count' => $correctCount,
                ':total_attempts' => $totalAttempts,
                ':mastered' => $isMastered
            ]);
            
            $result = [
                'word_id' => $wordId,
                'correct_count' => $correctCount,
                'total_attempts' => $totalAttempts,
                'mastered' => false
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
                
                // Insert or update
                $stmt = $pdo->prepare("
                    INSERT INTO user_progress 
                        (device_id, word_id, correct_count, total_attempts, mastered, last_reviewed, created_at, updated_at)
                    VALUES 
                        (:device_id, :word_id, :correct_count, :total_attempts, :mastered, :last_reviewed, NOW(), NOW())
                    ON DUPLICATE KEY UPDATE
                        correct_count = VALUES(correct_count),
                        total_attempts = VALUES(total_attempts),
                        mastered = VALUES(mastered),
                        last_reviewed = VALUES(last_reviewed),
                        updated_at = NOW()
                ");
                
                $stmt->execute([
                    ':device_id' => $deviceId,
                    ':word_id' => (int)$wordId,
                    ':correct_count' => $correctCount,
                    ':total_attempts' => $totalAttempts,
                    ':mastered' => $isMastered ? 1 : 0,
                    ':last_reviewed' => $lastReview
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
// HELPER FUNCTIONS
// ============================================================================

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
