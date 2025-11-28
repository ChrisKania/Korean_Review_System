<?php
/**
 * Reset Schedule Tool - Move all cards to today
 * Korean Learning System
 */

require_once 'config.php';

$pdo = getDBConnection();
$deviceId = $_GET['device_id'] ?? null;
$confirm = $_GET['confirm'] ?? null;

if (!$deviceId) {
    echo "<h1>Reset Review Schedule</h1>";
    echo "<p>Please provide device_id parameter</p>";
    exit;
}

if ($confirm !== 'yes') {
    echo "<h1>⚠️ Reset Review Schedule</h1>";
    echo "<p><strong>Device ID:</strong> $deviceId</p>";
    echo "<hr>";
    echo "<p>This will reset ALL your cards to be reviewed TODAY.</p>";
    echo "<p><strong>Warning:</strong> This will reset your spaced repetition progress!</p>";
    echo "<p>Your statistics (correct/total attempts) will be preserved.</p>";
    echo "<hr>";
    echo "<p><a href='reset-schedule.php?device_id=$deviceId&confirm=yes' style='background: red; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>YES, RESET ALL CARDS TO TODAY</a></p>";
    echo "<p><a href='diagnostic.php?device_id=$deviceId'>Cancel and go back</a></p>";
    exit;
}

// Perform reset
try {
    $stmt = $pdo->prepare("
        UPDATE user_progress
        SET
            next_review_date = CURDATE(),
            review_interval_days = 0,
            updated_at = NOW()
        WHERE device_id = :device_id
            AND mastered = 0
    ");

    $stmt->execute([':device_id' => $deviceId]);
    $affected = $stmt->rowCount();

    echo "<h1>✅ Schedule Reset Complete</h1>";
    echo "<p><strong>Cards reset:</strong> $affected</p>";
    echo "<p>All non-mastered cards are now scheduled for review today!</p>";
    echo "<hr>";
    echo "<p><a href='../index.html'>Go back to app</a></p>";
    echo "<p><a href='diagnostic.php?device_id=$deviceId'>View diagnostic</a></p>";

} catch (PDOException $e) {
    echo "<h1>❌ Error</h1>";
    echo "<p>Failed to reset schedule: " . $e->getMessage() . "</p>";
}
?>
