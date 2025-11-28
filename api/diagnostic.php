<?php
/**
 * Diagnostic Tool - Check Review Schedule
 * Korean Learning System
 */

require_once 'config.php';

$pdo = getDBConnection();
$deviceId = $_GET['device_id'] ?? null;

if (!$deviceId) {
    echo "<h1>Review Schedule Diagnostic</h1>";
    echo "<p>Please provide device_id parameter</p>";
    echo "<p>Example: diagnostic.php?device_id=device_854d31a4-c349-44e6-a6e5-7dc33e842733</p>";
    exit;
}

echo "<h1>📊 Review Schedule Diagnostic</h1>";
echo "<p><strong>Device ID:</strong> $deviceId</p>";
echo "<hr>";

// Query 1: Overall stats
echo "<h2>📈 Overall Statistics</h2>";
$stmt = $pdo->prepare("
    SELECT
        COUNT(*) as total_cards,
        SUM(CASE WHEN total_attempts > 0 THEN 1 ELSE 0 END) as reviewed_cards,
        SUM(CASE WHEN mastered = 1 THEN 1 ELSE 0 END) as mastered_cards,
        SUM(correct_count) as total_correct,
        SUM(total_attempts) as total_attempts
    FROM user_progress
    WHERE device_id = :device_id
");
$stmt->execute([':device_id' => $deviceId]);
$stats = $stmt->fetch(PDO::FETCH_ASSOC);

echo "<table border='1' cellpadding='10'>";
echo "<tr><th>Total Cards</th><td>{$stats['total_cards']}</td></tr>";
echo "<tr><th>Reviewed Cards</th><td>{$stats['reviewed_cards']}</td></tr>";
echo "<tr><th>Mastered Cards</th><td>{$stats['mastered_cards']}</td></tr>";
echo "<tr><th>Total Correct</th><td>{$stats['total_correct']}</td></tr>";
echo "<tr><th>Total Attempts</th><td>{$stats['total_attempts']}</td></tr>";
echo "</table>";

// Query 2: Schedule breakdown
echo "<h2>📅 Review Schedule Breakdown</h2>";
$stmt = $pdo->prepare("
    SELECT
        next_review_date,
        COUNT(*) as cards_count,
        MIN(review_interval_days) as min_interval,
        MAX(review_interval_days) as max_interval,
        AVG(total_attempts) as avg_attempts
    FROM user_progress
    WHERE device_id = :device_id
        AND mastered = 0
    GROUP BY next_review_date
    ORDER BY next_review_date
    LIMIT 30
");
$stmt->execute([':device_id' => $deviceId]);
$schedule = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<table border='1' cellpadding='10'>";
echo "<tr><th>Date</th><th>Cards Due</th><th>Interval Range</th><th>Avg Attempts</th><th>Status</th></tr>";

$today = date('Y-m-d');
$tomorrow = date('Y-m-d', strtotime('+1 day'));

foreach ($schedule as $row) {
    $date = $row['next_review_date'];
    $status = '';
    if ($date < $today) $status = '⚠️ OVERDUE';
    elseif ($date == $today) $status = '🔴 TODAY';
    elseif ($date == $tomorrow) $status = '🟡 TOMORROW';
    else $status = '🟢 FUTURE';

    echo "<tr>";
    echo "<td><strong>$date</strong></td>";
    echo "<td>{$row['cards_count']}</td>";
    echo "<td>{$row['min_interval']} - {$row['max_interval']} days</td>";
    echo "<td>" . round($row['avg_attempts'], 1) . "</td>";
    echo "<td>$status</td>";
    echo "</tr>";
}
echo "</table>";

// Query 3: Cards due today (detailed)
echo "<h2>🔍 Cards Due Today (Details)</h2>";
$stmt = $pdo->prepare("
    SELECT
        up.word_id,
        v.korean,
        v.meaning,
        up.total_attempts,
        up.correct_count,
        up.review_interval_days,
        up.next_review_date,
        up.last_reviewed
    FROM user_progress up
    JOIN vocabulary v ON up.word_id = v.id
    WHERE up.device_id = :device_id
        AND up.next_review_date <= CURDATE()
        AND up.mastered = 0
    ORDER BY up.next_review_date
    LIMIT 20
");
$stmt->execute([':device_id' => $deviceId]);
$dueCards = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($dueCards) > 0) {
    echo "<table border='1' cellpadding='10'>";
    echo "<tr><th>Word</th><th>Meaning</th><th>Attempts</th><th>Correct</th><th>Interval</th><th>Due Date</th><th>Last Review</th></tr>";
    foreach ($dueCards as $card) {
        echo "<tr>";
        echo "<td>{$card['korean']}</td>";
        echo "<td>{$card['meaning']}</td>";
        echo "<td>{$card['total_attempts']}</td>";
        echo "<td>{$card['correct_count']}</td>";
        echo "<td>{$card['review_interval_days']} days</td>";
        echo "<td>{$card['next_review_date']}</td>";
        echo "<td>{$card['last_reviewed']}</td>";
        echo "</tr>";
    }
    echo "</table>";
} else {
    echo "<p><strong>✅ No cards due today!</strong></p>";
}

// Query 4: Sample of future cards
echo "<h2>🔮 Sample of Upcoming Cards</h2>";
$stmt = $pdo->prepare("
    SELECT
        up.word_id,
        v.korean,
        v.meaning,
        up.total_attempts,
        up.correct_count,
        up.review_interval_days,
        up.next_review_date,
        up.last_reviewed
    FROM user_progress up
    JOIN vocabulary v ON up.word_id = v.id
    WHERE up.device_id = :device_id
        AND up.next_review_date > CURDATE()
        AND up.mastered = 0
    ORDER BY up.next_review_date
    LIMIT 10
");
$stmt->execute([':device_id' => $deviceId]);
$futureCards = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<table border='1' cellpadding='10'>";
echo "<tr><th>Word</th><th>Meaning</th><th>Attempts</th><th>Correct</th><th>Interval</th><th>Due Date</th><th>Days Away</th></tr>";
foreach ($futureCards as $card) {
    $daysAway = floor((strtotime($card['next_review_date']) - strtotime($today)) / 86400);
    echo "<tr>";
    echo "<td>{$card['korean']}</td>";
    echo "<td>{$card['meaning']}</td>";
    echo "<td>{$card['total_attempts']}</td>";
    echo "<td>{$card['correct_count']}</td>";
    echo "<td>{$card['review_interval_days']} days</td>";
    echo "<td>{$card['next_review_date']}</td>";
    echo "<td>+$daysAway days</td>";
    echo "</tr>";
}
echo "</table>";

echo "<hr>";
echo "<h2>🛠️ Fix Options</h2>";
echo "<p>If cards are scheduled incorrectly, you can:</p>";
echo "<ol>";
echo "<li><a href='reset-schedule.php?device_id=$deviceId'>Reset all cards to review today</a> (Nuclear option)</li>";
echo "<li>Wait for the scheduled dates (recommended if using spaced repetition)</li>";
echo "<li>Use the 'Practice Mastered Cards' button in Settings to practice early</li>";
echo "</ol>";
?>
