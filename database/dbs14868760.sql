-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Host: db5018828738.hosting-data.io
-- Generation Time: Oct 28, 2025 at 10:16 AM
-- Server version: 10.11.14-MariaDB-log
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbs14868760`
--

-- --------------------------------------------------------

--
-- Table structure for table `lessons`
--

CREATE TABLE `lessons` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `week` int(11) NOT NULL,
  `phase` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lessons`
--

INSERT INTO `lessons` (`id`, `title`, `week`, `phase`, `description`, `created_at`) VALUES
(1, 'Greetings & Introduction', 1, 1, 'Hello, I am... (Basic introductions)', '2025-10-17 20:36:57'),
(2, 'Where Are You From?', 1, 1, 'Countries, nationalities', '2025-10-17 20:36:57'),
(3, 'Polite Expressions', 1, 1, 'Nice to meet you (Polite expressions)', '2025-10-17 20:36:57'),
(4, 'Yes/No and Basic Responses', 1, 1, 'Basic responses', '2025-10-17 20:36:57'),
(5, 'Week 1 Review & Consolidation', 1, 1, 'Review of Week 1', '2025-10-17 20:36:57'),
(6, 'What Do You Do?', 2, 1, 'Occupations and hobbies', '2025-10-17 20:36:57'),
(7, 'Family Members', 2, 1, 'Family vocabulary', '2025-10-17 20:36:57'),
(8, 'Age and Numbers', 2, 1, 'Numbers 1-100 and age', '2025-10-17 20:36:57'),
(9, 'Telephone Numbers & Contact Info', 2, 1, 'Learn to ask for and share contact information including phone numbers, email, and messaging apps', '2025-10-22 06:46:22'),
(10, 'Review & Conversation Practice', 2, 1, 'Week 2 review and consolidation', '2025-10-22 06:21:35'),
(11, 'This/That/It', 3, 1, 'Learn demonstratives and how to point things out', '2025-10-22 06:21:35'),
(12, 'What is this?', 3, 1, 'Basic questions', '2025-10-22 06:21:35'),
(13, 'I like/I don\'t like', 3, 1, 'Expressing preferences', '2025-10-22 06:21:35'),
(14, 'I have/I don\'t have', 3, 1, 'Possession', '2025-10-22 06:21:35'),
(15, 'Review Week', 3, 1, 'Week 3 consolidation', '2025-10-22 06:21:35');

-- --------------------------------------------------------

--
-- Table structure for table `session_stats`
--

CREATE TABLE `session_stats` (
  `id` int(11) NOT NULL,
  `device_id` varchar(100) NOT NULL,
  `study_date` date NOT NULL,
  `cards_reviewed` int(11) DEFAULT 0,
  `correct_answers` int(11) DEFAULT 0,
  `accuracy` decimal(5,2) DEFAULT 0.00,
  `study_time_minutes` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `session_stats`
--

INSERT INTO `session_stats` (`id`, `device_id`, `study_date`, `cards_reviewed`, `correct_answers`, `accuracy`, `study_time_minutes`, `created_at`, `updated_at`) VALUES
(1, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', '2025-10-22', 7, 0, '60.00', 0, '2025-10-22 20:50:58', '2025-10-22 20:52:38'),
(9, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', '2025-10-24', 65, 0, '74.50', 0, '2025-10-23 22:03:18', '2025-10-23 22:16:07'),
(99, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', '2025-10-27', 41, 0, '72.20', 0, '2025-10-27 07:53:40', '2025-10-27 08:05:14');

-- --------------------------------------------------------

--
-- Table structure for table `user_progress`
--

CREATE TABLE `user_progress` (
  `id` int(11) NOT NULL,
  `device_id` varchar(100) NOT NULL,
  `word_id` int(11) NOT NULL,
  `correct_count` int(11) DEFAULT 0,
  `total_attempts` int(11) DEFAULT 0,
  `mastered` tinyint(1) DEFAULT 0,
  `last_reviewed` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_progress`
--

INSERT INTO `user_progress` (`id`, `device_id`, `word_id`, `correct_count`, `total_attempts`, `mastered`, `last_reviewed`, `created_at`, `updated_at`) VALUES
(1, 'device_c40e25b1-c7b9-4b93-b844-a0cfbd9cf060', 1, 1, 1, 0, '2025-10-19 08:10:04', '2025-10-19 08:10:04', '2025-10-19 08:10:04'),
(2, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 6, 3, 3, 1, '2025-10-21 20:44:14', '2025-10-19 08:11:55', '2025-10-21 20:44:14'),
(3, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 25, 3, 4, 0, '2025-10-23 22:11:22', '2025-10-19 08:15:45', '2025-10-23 22:11:22'),
(4, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 18, 3, 3, 1, '2025-10-23 22:12:37', '2025-10-19 08:25:30', '2025-10-23 22:12:37'),
(5, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 35, 3, 3, 1, '2025-10-27 08:01:15', '2025-10-19 08:25:37', '2025-10-27 08:01:15'),
(6, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 9, 3, 5, 0, '2025-10-23 22:03:53', '2025-10-19 08:25:55', '2025-10-23 22:03:53'),
(7, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 30, 3, 3, 1, '2025-10-23 22:12:43', '2025-10-19 08:26:15', '2025-10-23 22:12:43'),
(8, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 28, 4, 4, 1, '2025-10-27 08:02:00', '2025-10-19 08:29:41', '2025-10-27 08:02:00'),
(9, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 38, 3, 3, 1, '2025-10-23 22:04:35', '2025-10-19 08:29:50', '2025-10-23 22:04:35'),
(10, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 46, 3, 6, 0, '2025-10-23 22:04:44', '2025-10-19 08:34:57', '2025-10-23 22:04:44'),
(11, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 39, 3, 5, 0, '2025-10-23 22:04:38', '2025-10-19 08:35:06', '2025-10-23 22:04:38'),
(12, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 1, 4, 4, 1, '2025-10-27 07:53:40', '2025-10-19 08:35:10', '2025-10-27 07:53:40'),
(13, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 51, 4, 5, 1, '2025-10-27 08:00:08', '2025-10-19 08:35:20', '2025-10-27 08:00:08'),
(14, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 49, 3, 3, 1, '2025-10-23 22:10:25', '2025-10-19 08:35:35', '2025-10-23 22:10:25'),
(15, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 33, 4, 4, 1, '2025-10-27 07:57:19', '2025-10-19 08:35:41', '2025-10-27 07:57:19'),
(16, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 8, 3, 7, 0, '2025-10-23 22:04:47', '2025-10-19 08:35:52', '2025-10-23 22:04:47'),
(17, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 2, 4, 4, 1, '2025-10-27 08:01:05', '2025-10-19 08:35:56', '2025-10-27 08:01:05'),
(18, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 45, 4, 8, 0, '2025-10-27 07:58:34', '2025-10-19 08:36:10', '2025-10-27 07:58:34'),
(19, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 19, 3, 3, 1, '2025-10-23 22:14:32', '2025-10-19 08:36:14', '2025-10-23 22:14:32'),
(20, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 36, 4, 4, 1, '2025-10-27 07:57:46', '2025-10-19 08:36:24', '2025-10-27 07:57:46'),
(21, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 43, 4, 8, 0, '2025-10-27 08:04:44', '2025-10-19 08:36:57', '2025-10-27 08:04:44'),
(22, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 26, 4, 6, 0, '2025-10-27 08:03:21', '2025-10-19 08:37:10', '2025-10-27 08:03:21'),
(23, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 29, 3, 3, 1, '2025-10-23 22:12:40', '2025-10-19 08:37:36', '2025-10-23 22:12:40'),
(24, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 50, 4, 4, 1, '2025-10-27 08:05:05', '2025-10-19 08:37:40', '2025-10-27 08:05:05'),
(25, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 34, 3, 3, 1, '2025-10-23 22:10:55', '2025-10-19 08:37:45', '2025-10-23 22:10:55'),
(26, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 21, 3, 3, 1, '2025-10-23 22:12:07', '2025-10-19 08:38:01', '2025-10-23 22:12:07'),
(27, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 48, 3, 7, 0, '2025-10-23 22:15:33', '2025-10-19 08:39:06', '2025-10-23 22:15:33'),
(28, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 24, 4, 4, 1, '2025-10-27 08:01:02', '2025-10-19 08:39:21', '2025-10-27 08:01:02'),
(29, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 10, 4, 4, 1, '2025-10-23 22:15:37', '2025-10-19 08:39:29', '2025-10-23 22:15:37'),
(30, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 3, 3, 3, 1, '2025-10-23 22:10:52', '2025-10-19 08:39:39', '2025-10-23 22:10:52'),
(31, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 27, 4, 4, 1, '2025-10-27 08:04:25', '2025-10-19 08:39:48', '2025-10-27 08:04:25'),
(32, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 20, 3, 3, 1, '2025-10-23 22:14:07', '2025-10-19 08:40:00', '2025-10-23 22:14:07'),
(33, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 47, 3, 5, 0, '2025-10-23 22:06:00', '2025-10-19 08:40:19', '2025-10-23 22:06:00'),
(34, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 23, 5, 5, 1, '2025-10-27 07:59:06', '2025-10-19 08:40:36', '2025-10-27 07:59:06'),
(35, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 13, 3, 3, 1, '2025-10-23 22:10:50', '2025-10-19 08:40:39', '2025-10-23 22:10:50'),
(36, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 41, 4, 5, 1, '2025-10-27 07:57:04', '2025-10-19 08:40:46', '2025-10-27 07:57:04'),
(37, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 17, 3, 3, 1, '2025-10-23 22:07:12', '2025-10-19 08:40:57', '2025-10-23 22:07:12'),
(38, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 11, 4, 4, 1, '2025-10-27 07:58:11', '2025-10-19 08:42:50', '2025-10-27 07:58:11'),
(39, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 14, 4, 4, 1, '2025-10-27 07:56:10', '2025-10-19 08:43:11', '2025-10-27 07:56:10'),
(40, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 37, 4, 6, 0, '2025-10-27 07:59:11', '2025-10-19 08:45:12', '2025-10-27 07:59:11'),
(41, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 16, 3, 3, 1, '2025-10-23 22:07:08', '2025-10-19 08:45:22', '2025-10-23 22:07:08'),
(42, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 32, 4, 4, 1, '2025-10-27 07:57:17', '2025-10-19 08:45:25', '2025-10-27 07:57:17'),
(43, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 22, 4, 4, 1, '2025-10-27 07:56:23', '2025-10-19 08:45:35', '2025-10-27 07:56:23'),
(44, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 40, 3, 3, 1, '2025-10-23 22:13:58', '2025-10-19 08:45:51', '2025-10-23 22:13:58'),
(45, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 31, 3, 3, 1, '2025-10-23 22:07:17', '2025-10-19 08:45:54', '2025-10-23 22:07:17'),
(46, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 7, 4, 4, 1, '2025-10-27 07:56:45', '2025-10-19 08:45:59', '2025-10-27 07:56:45'),
(47, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 5, 3, 3, 1, '2025-10-27 08:04:49', '2025-10-19 08:46:05', '2025-10-27 08:04:49'),
(48, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 15, 3, 3, 1, '2025-10-23 22:04:49', '2025-10-19 08:46:13', '2025-10-23 22:04:49'),
(49, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 42, 5, 7, 0, '2025-10-27 07:56:19', '2025-10-19 08:46:26', '2025-10-27 07:56:19'),
(50, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 4, 3, 3, 1, '2025-10-23 22:03:42', '2025-10-19 08:46:39', '2025-10-23 22:03:42'),
(51, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 12, 3, 3, 1, '2025-10-23 22:06:44', '2025-10-19 08:47:00', '2025-10-23 22:06:44'),
(52, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 44, 4, 5, 1, '2025-10-27 07:57:00', '2025-10-19 08:47:16', '2025-10-27 07:57:00'),
(53, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 78, 2, 7, 0, '2025-10-27 08:04:30', '2025-10-22 20:52:03', '2025-10-27 08:04:30'),
(54, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 83, 2, 6, 0, '2025-10-27 08:00:57', '2025-10-22 20:52:16', '2025-10-27 08:00:57'),
(55, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 84, 2, 4, 0, '2025-10-27 08:05:00', '2025-10-22 20:52:27', '2025-10-27 08:05:00'),
(56, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 82, 2, 7, 0, '2025-10-27 07:56:41', '2025-10-22 20:52:34', '2025-10-27 07:56:41'),
(57, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 87, 2, 2, 0, '2025-10-27 08:00:00', '2025-10-23 22:04:55', '2025-10-27 08:00:00'),
(58, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 80, 2, 5, 0, '2025-10-27 07:57:32', '2025-10-23 22:05:25', '2025-10-27 07:57:32'),
(59, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 81, 2, 3, 0, '2025-10-27 07:58:00', '2025-10-23 22:06:43', '2025-10-27 07:58:00'),
(60, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 75, 2, 2, 0, '2025-10-27 08:04:23', '2025-10-23 22:08:43', '2025-10-27 08:04:23'),
(61, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 88, 2, 4, 0, '2025-10-27 07:58:46', '2025-10-23 22:09:09', '2025-10-27 07:58:46'),
(62, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 72, 2, 3, 0, '2025-10-27 08:05:14', '2025-10-23 22:09:29', '2025-10-27 08:05:14'),
(63, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 74, 2, 3, 0, '2025-10-27 07:58:17', '2025-10-23 22:09:48', '2025-10-27 07:58:17'),
(64, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 85, 2, 4, 0, '2025-10-27 08:03:34', '2025-10-23 22:10:22', '2025-10-27 08:03:34'),
(65, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 76, 2, 2, 0, '2025-10-27 07:56:53', '2025-10-23 22:11:05', '2025-10-27 07:56:53'),
(66, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 79, 2, 3, 0, '2025-10-27 07:56:02', '2025-10-23 22:11:53', '2025-10-27 07:56:02'),
(67, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 86, 2, 5, 0, '2025-10-27 08:04:16', '2025-10-23 22:13:36', '2025-10-27 08:04:16'),
(68, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 73, 2, 3, 0, '2025-10-27 07:57:08', '2025-10-23 22:15:13', '2025-10-27 07:57:08'),
(69, 'device_854d31a4-c349-44e6-a6e5-7dc33e842733', 77, 2, 4, 0, '2025-10-27 07:58:57', '2025-10-23 22:16:04', '2025-10-27 07:58:57');

-- --------------------------------------------------------

--
-- Table structure for table `vocabulary`
--

CREATE TABLE `vocabulary` (
  `id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `korean` varchar(200) NOT NULL,
  `romanization` varchar(200) NOT NULL,
  `meaning` varchar(300) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `hint` text DEFAULT NULL,
  `example_sentence` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vocabulary`
--

INSERT INTO `vocabulary` (`id`, `lesson_id`, `korean`, `romanization`, `meaning`, `category`, `hint`, `example_sentence`, `created_at`) VALUES
(1, 1, '안녕하세요', 'annyeonghaseyo', 'Hello', 'greeting', NULL, NULL, '2025-10-17 20:36:57'),
(2, 1, '저는', 'jeoneun', 'I am', 'grammar', NULL, NULL, '2025-10-17 20:36:57'),
(3, 1, '입니다', 'imnida', 'am/is/are', 'grammar', NULL, NULL, '2025-10-17 20:36:57'),
(4, 1, '감사합니다', 'gamsahamnida', 'Thank you', 'greeting', NULL, NULL, '2025-10-17 20:36:57'),
(5, 2, '어디에서 왔어요?', 'eodieseo wasseoyo?', 'Where are you from?', 'question', NULL, NULL, '2025-10-17 20:36:57'),
(6, 2, '영국', 'yeongguk', 'United Kingdom', 'country', NULL, NULL, '2025-10-17 20:36:57'),
(7, 2, '한국', 'hanguk', 'Korea', 'country', NULL, NULL, '2025-10-17 20:36:57'),
(8, 2, '에서', 'eseo', 'from (particle)', 'grammar', NULL, NULL, '2025-10-17 20:36:57'),
(9, 2, '왔어요', 'wasseoyo', 'came', 'verb', NULL, NULL, '2025-10-17 20:36:57'),
(10, 3, '만나서 반갑습니다', 'mannaseo bangapseumnida', 'Nice to meet you', 'greeting', NULL, NULL, '2025-10-17 20:36:57'),
(11, 3, '잘 부탁합니다', 'jal butakamnida', 'Please treat me well', 'greeting', NULL, NULL, '2025-10-17 20:36:57'),
(12, 3, '네', 'ne', 'Yes', 'response', NULL, NULL, '2025-10-17 20:36:57'),
(13, 3, '아니요', 'aniyo', 'No', 'response', NULL, NULL, '2025-10-17 20:36:57'),
(14, 4, '괜찮아요', 'gwaenchanayo', 'It is okay', 'response', NULL, NULL, '2025-10-17 20:36:57'),
(15, 4, '사람', 'saram', 'person', 'noun', NULL, NULL, '2025-10-17 20:36:57'),
(16, 4, '학생', 'haksaeng', 'student', 'noun', NULL, NULL, '2025-10-17 20:36:57'),
(17, 6, '뭐 해요?', 'mwo haeyo?', 'What do you do?', 'question', NULL, NULL, '2025-10-17 20:36:57'),
(18, 6, 'VFX 아티스트', 'VFX atiseuteu', 'VFX artist', 'occupation', NULL, NULL, '2025-10-17 20:36:57'),
(19, 6, '예요', 'yeyo', 'am/is/are (casual)', 'grammar', NULL, NULL, '2025-10-17 20:36:57'),
(20, 7, '가족', 'gajok', 'family', 'noun', NULL, NULL, '2025-10-17 20:36:57'),
(21, 7, '엄마', 'eomma', 'mom', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(22, 7, '아빠', 'appa', 'dad', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(23, 7, '형제', 'hyeongje', 'siblings', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(24, 7, '오빠', 'oppa', 'older brother (by female)', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(25, 7, '언니', 'eonni', 'older sister (by female)', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(26, 7, '동생', 'dongsaeng', 'younger sibling', 'family', NULL, NULL, '2025-10-17 20:36:57'),
(27, 7, '있어요', 'isseoyo', 'have/there is', 'verb', NULL, NULL, '2025-10-17 20:36:57'),
(28, 7, '없어요', 'eopseoyo', 'do not have/there is not', 'verb', NULL, NULL, '2025-10-17 20:36:57'),
(29, 7, '몇', 'myeot', 'how many', 'question', NULL, NULL, '2025-10-17 20:36:57'),
(30, 7, '명', 'myeong', 'counter for people', 'counter', NULL, NULL, '2025-10-17 20:36:57'),
(31, 8, '하나', 'hana', 'one', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(32, 8, '둘', 'dul', 'two', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(33, 8, '셋', 'set', 'three', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(34, 8, '넷', 'net', 'four', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(35, 8, '다섯', 'daseot', 'five', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(36, 8, '여섯', 'yeoseot', 'six', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(37, 8, '일곱', 'ilgop', 'seven', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(38, 8, '여덟', 'yeodeol', 'eight', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(39, 8, '아홉', 'ahop', 'nine', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(40, 8, '열', 'yeol', 'ten', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(41, 8, '스물', 'seumul', 'twenty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(42, 8, '서른', 'seoreun', 'thirty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(43, 8, '마흔', 'maheun', 'forty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(44, 8, '쉰', 'swin', 'fifty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(45, 8, '예순', 'yesun', 'sixty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(46, 8, '일흔', 'ilheun', 'seventy', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(47, 8, '여든', 'yeodeun', 'eighty', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(48, 8, '아흔', 'aheun', 'ninety', 'number', NULL, NULL, '2025-10-17 20:36:57'),
(49, 8, '개', 'gae', 'counter for things', 'counter', NULL, NULL, '2025-10-17 20:36:57'),
(50, 8, '몇 살이에요?', 'myeot salieyo?', 'How old are you?', 'question', NULL, NULL, '2025-10-17 20:36:57'),
(51, 8, '살', 'sal', 'years old (age counter)', 'counter', NULL, NULL, '2025-10-17 20:36:57'),
(72, 9, '전화번호', 'jeonhwa beonho', 'phone number', 'noun', 'Combination: 전화 (phone) + 번호 (number)', '전화번호가 뭐예요?', '2025-10-22 06:46:22'),
(73, 9, '전화', 'jeonhwa', 'telephone, phone call', 'noun', 'Can mean both device and action', '전화 주세요', '2025-10-22 06:46:22'),
(74, 9, '번호', 'beonho', 'number', 'noun', 'Any type of number', '방 번호는 몇이에요?', '2025-10-22 06:46:22'),
(75, 9, '휴대폰', 'hyudaepon', 'mobile phone, cell phone', 'noun', 'Literally \"portable phone\"', '휴대폰이 있어요?', '2025-10-22 06:46:22'),
(76, 9, '이메일', 'imeil', 'email', 'noun', 'Loan word from English', '이메일 주소를 알려주세요', '2025-10-22 06:46:22'),
(77, 9, '주소', 'juso', 'address', 'noun', 'Physical or email address', '집 주소가 어디예요?', '2025-10-22 06:46:22'),
(78, 9, '연락하다', 'yeollakhada', 'to contact', 'verb', 'Conjugates to 연락해요', '나중에 연락할게요', '2025-10-22 06:46:22'),
(79, 9, '전화하다', 'jeonhwahada', 'to call (on phone)', 'verb', 'Conjugates to 전화해요', '내일 전화할게요', '2025-10-22 06:46:22'),
(80, 9, '보내다', 'bonaeda', 'to send', 'verb', 'Send messages, emails, etc.', '문자 보낼게요', '2025-10-22 06:46:22'),
(81, 9, '전화번호가 뭐예요?', 'jeonhwa beonhoga mwoyeyo?', 'What is your phone number?', 'question', 'Polite casual form', NULL, '2025-10-22 06:46:22'),
(82, 9, '전화번호 좀 알려주세요', 'jeonhwa beonho jom allyeojuseyo', 'Please tell me your phone number', 'phrase', 'More polite request', NULL, '2025-10-22 06:46:22'),
(83, 9, '연락처가 어떻게 되세요?', 'yeollakchoga eotteoke doeseyo?', 'What is your contact information?', 'question', 'Very formal/polite', NULL, '2025-10-22 06:46:22'),
(84, 9, '제 전화번호는...', 'je jeonhwa beonhoneun...', 'My phone number is...', 'phrase', 'Use before stating number', '제 전화번호는 010-1234-5678이에요', '2025-10-22 06:46:22'),
(85, 9, '여기 제 명함이에요', 'yeogi je myeonghamieyo', 'Here is my business card', 'phrase', 'Professional context', NULL, '2025-10-22 06:46:22'),
(86, 9, '이메일 주소 알려드릴게요', 'imeil juso allyeodeurilgeyo', 'I will give you my email address', 'phrase', 'Polite future tense', NULL, '2025-10-22 06:46:22'),
(87, 9, '카카오톡', 'kakaotok', 'KakaoTalk (messaging app)', 'noun', 'Most popular app in Korea', '카카오톡 하세요?', '2025-10-22 06:46:22'),
(88, 9, '문자', 'munja', 'text message', 'noun', 'Short for 문자 메시지', '문자 보냈어요', '2025-10-22 06:46:22'),
(89, 11, '이것', 'igeot', 'this (thing)', 'demonstrative', 'Near the speaker', '이것이 뭐예요?', '2025-10-28 09:34:02'),
(90, 11, '그것', 'geugeot', 'that (thing)', 'demonstrative', 'Near the listener', '그것이 뭐예요?', '2025-10-28 09:34:02'),
(91, 11, '저것', 'jeogeot', 'that (thing over there)', 'demonstrative', 'Far from both', '저것이 뭐예요?', '2025-10-28 09:34:02'),
(92, 11, '이거', 'igeo', 'this (informal)', 'demonstrative', 'Casual form of 이것', '이거 뭐예요?', '2025-10-28 09:34:02'),
(93, 11, '그거', 'geugeo', 'that (informal)', 'demonstrative', 'Casual form of 그것', '그거 뭐예요?', '2025-10-28 09:34:02'),
(94, 11, '저거', 'jeogeo', 'that over there (informal)', 'demonstrative', 'Casual form of 저것', '저거 뭐예요?', '2025-10-28 09:34:02'),
(95, 11, '이', 'i', 'this (modifier)', 'demonstrative', 'Used before nouns', '이 사람', '2025-10-28 09:34:02'),
(96, 11, '그', 'geu', 'that (modifier)', 'demonstrative', 'Used before nouns', '그 사람', '2025-10-28 09:34:02'),
(97, 11, '저', 'jeo', 'that (modifier - far)', 'demonstrative', 'Used before nouns', '저 사람', '2025-10-28 09:34:02'),
(98, 11, '이게 뭐예요?', 'ige mwoyeyo?', 'What is this?', 'question', 'Asking about nearby objects', NULL, '2025-10-28 09:34:02'),
(99, 11, '그게 뭐예요?', 'geuge mwoyeyo?', 'What is that?', 'question', 'Asking about objects near listener', NULL, '2025-10-28 09:34:02'),
(100, 11, '이건 뭐예요?', 'igeon mwoyeyo?', 'What is this? (topic)', 'question', '이것은 shortened form', NULL, '2025-10-28 09:34:02'),
(101, 11, '이 사람', 'i saram', 'this person', 'noun', 'Pointing to someone nearby', NULL, '2025-10-28 09:34:02'),
(102, 11, '그 사람', 'geu saram', 'that person', 'noun', 'Referring to someone', NULL, '2025-10-28 09:34:02'),
(103, 11, '여기', 'yeogi', 'here', 'location', 'This place', '여기 있어요', '2025-10-28 09:34:02'),
(104, 11, '거기', 'geogi', 'there', 'location', 'That place (near listener)', '거기 있어요', '2025-10-28 09:34:02'),
(105, 11, '저기', 'jeogi', 'over there', 'location', 'That place (far away)', '저기 있어요', '2025-10-28 09:34:02');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `lessons`
--
ALTER TABLE `lessons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `session_stats`
--
ALTER TABLE `session_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_device_date` (`device_id`,`study_date`),
  ADD KEY `idx_device` (`device_id`),
  ADD KEY `idx_date` (`study_date`);

--
-- Indexes for table `user_progress`
--
ALTER TABLE `user_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_device_word` (`device_id`,`word_id`),
  ADD KEY `word_id` (`word_id`),
  ADD KEY `idx_device` (`device_id`),
  ADD KEY `idx_mastered` (`mastered`),
  ADD KEY `idx_last_reviewed` (`last_reviewed`);

--
-- Indexes for table `vocabulary`
--
ALTER TABLE `vocabulary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_lesson` (`lesson_id`),
  ADD KEY `idx_category` (`category`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `session_stats`
--
ALTER TABLE `session_stats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT for table `user_progress`
--
ALTER TABLE `user_progress`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `vocabulary`
--
ALTER TABLE `vocabulary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `user_progress`
--
ALTER TABLE `user_progress`
  ADD CONSTRAINT `user_progress_ibfk_1` FOREIGN KEY (`word_id`) REFERENCES `vocabulary` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vocabulary`
--
ALTER TABLE `vocabulary`
  ADD CONSTRAINT `vocabulary_ibfk_1` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
