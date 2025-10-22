<?php
/**
 * Test API Endpoint
 * Use this to verify your database connection and API setup
 * 
 * Access: yoursite.com/api/test.php
 */

require_once 'config.php';

// Test database connection
try {
    $pdo = getDBConnection();
    
    // Get counts from each table
    $lessonCount = $pdo->query("SELECT COUNT(*) FROM lessons")->fetchColumn();
    $vocabCount = $pdo->query("SELECT COUNT(*) FROM vocabulary")->fetchColumn();
    $progressCount = $pdo->query("SELECT COUNT(*) FROM user_progress")->fetchColumn();
    $statsCount = $pdo->query("SELECT COUNT(*) FROM session_stats")->fetchColumn();
    
    // Get sample lesson
    $stmt = $pdo->query("SELECT * FROM lessons LIMIT 1");
    $sampleLesson = $stmt->fetch();
    
    // Get sample vocabulary
    $stmt = $pdo->query("SELECT * FROM vocabulary LIMIT 3");
    $sampleVocab = $stmt->fetchAll();
    
    $testResults = [
        'database_connection' => 'SUCCESS',
        'timestamp' => date('Y-m-d H:i:s'),
        'php_version' => phpversion(),
        'tables' => [
            'lessons' => $lessonCount,
            'vocabulary' => $vocabCount,
            'user_progress' => $progressCount,
            'session_stats' => $statsCount
        ],
        'sample_data' => [
            'lesson' => $sampleLesson,
            'vocabulary' => $sampleVocab
        ],
        'config' => [
            'db_host' => DB_HOST,
            'db_name' => DB_NAME,
            'charset' => DB_CHARSET
        ]
    ];
    
    sendResponse(true, $testResults, 'API is working correctly! ✓');
    
} catch (PDOException $e) {
    sendResponse(false, [
        'error_type' => 'Database Connection Error',
        'error_message' => $e->getMessage(),
        'config_check' => [
            'db_host' => DB_HOST,
            'db_name' => DB_NAME,
            'db_user' => DB_USER,
            'note' => 'Please verify your database credentials in config.php'
        ]
    ], 'Database connection failed', 500);
} catch (Exception $e) {
    sendResponse(false, [
        'error_type' => 'General Error',
        'error_message' => $e->getMessage()
    ], 'API test failed', 500);
}
