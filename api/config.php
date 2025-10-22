<?php
/**
 * Database Configuration
 * Korean Learning System
 * 
 * INSTRUCTIONS:
 * 1. Update these values with your IONOS database credentials
 * 2. You can find these in your IONOS control panel
 */

// Database credentials - UPDATE THESE!
define('DB_HOST', 'db5018828738.hosting-data.io');  // Usually 'localhost' for IONOS
define('DB_NAME', 'dbs14868760');  // Your database name
define('DB_USER', 'dbu5555368');  // Your database username
define('DB_PASS', 'Uncork2-Very-Affix');  // Your database password
define('DB_CHARSET', 'utf8mb4');

// CORS settings (allows frontend to communicate with backend)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Error reporting (set to 0 in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

/**
 * Get database connection
 * @return PDO Database connection object
 */
function getDBConnection() {
    static $pdo = null;
    
    if ($pdo === null) {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];
            
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Database connection failed',
                'message' => $e->getMessage()
            ]);
            exit();
        }
    }
    
    return $pdo;
}

/**
 * Send JSON response
 * @param bool $success Success status
 * @param string $message Optional message
 * @param mixed $data Data to send
 * @param int $httpCode HTTP status code
 */
function sendResponse($success, $message = '', $data = null, $httpCode = 200) {
    http_response_code($httpCode);
    
    $response = ['success' => $success];
    
    if ($message) {
        $response['message'] = $message;
    }
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * Get device ID from request
 * @return string Device ID
 */
function getDeviceId() {
    $headers = getallheaders();
    
    if (isset($headers['X-Device-ID'])) {
        return $headers['X-Device-ID'];
    }
    
    if (isset($_GET['device_id'])) {
        return $_GET['device_id'];
    }
    
    if (isset($_POST['device_id'])) {
        return $_POST['device_id'];
    }
    
    return null;
}

/**
 * Validate device ID
 * @param string $deviceId Device ID to validate
 * @return bool True if valid
 */
function validateDeviceId($deviceId) {
    if (!$deviceId) {
        sendResponse(false, null, 'Device ID is required', 400);
        return false;
    }
    
    // Basic validation: alphanumeric, dashes, underscores, 10-100 chars
    if (!preg_match('/^[a-zA-Z0-9_-]{10,100}$/', $deviceId)) {
        sendResponse(false, null, 'Invalid device ID format', 400);
        return false;
    }
    
    return true;
}
