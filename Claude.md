# Claude.md - Korean Review System

**Project Context Document for AI Assistants**

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Purpose & Motivation](#purpose--motivation)
3. [Core Features](#core-features)
4. [Technical Architecture](#technical-architecture)
5. [Project Requirements](#project-requirements)
6. [Technical Direction](#technical-direction)
7. [Development Guidelines](#development-guidelines)
8. [Database Schema](#database-schema)
9. [API Reference](#api-reference)
10. [Future Roadmap](#future-roadmap)

---

## Project Overview

### What is This?

The **Korean Review System** is a comprehensive web-based Korean language learning platform that uses spaced repetition and flashcard-based learning to help users master Korean vocabulary and phrases. The system is designed to be simple, effective, and accessible across multiple devices without requiring user accounts.

### Key Characteristics

- **Single-page application** with dynamic content loading
- **Device-based authentication** (no login required)
- **Spaced repetition algorithm** for optimal learning
- **Multi-device synchronization** via export/import
- **Progress persistence** with MySQL backend
- **Text-to-speech** pronunciation support
- **Responsive design** for mobile and desktop

---

## Purpose & Motivation

### Why This Project Exists

1. **Targeted Learning**: Designed specifically for UK-based learners (particularly VFX artists and creative professionals) who want to learn conversational Korean
2. **No Friction**: Eliminates barriers to entry - no account creation, no complex setup, just start learning
3. **Proven Method**: Implements spaced repetition, a scientifically-backed learning technique
4. **Progressive Curriculum**: Structured lesson path from greetings to complex conversations (Lessons 1-60 planned)
5. **Accessibility**: Works on any device with a web browser, with automatic progress tracking

### Target Audience

- English speakers learning Korean
- Self-directed learners who prefer flashcard-based study
- Users who want to learn at their own pace
- People who study across multiple devices
- Learners focused on conversational Korean (not academic Korean)

---

## Core Features

### 1. Flashcard Review System

- **Smart Scheduling**: Spaced repetition algorithm determines when cards are due
- **Flip Interaction**: Click to reveal answer, immediate feedback
- **Difficulty Marking**: "I know this" vs "Difficult" buttons
- **Progress Tracking**: Visual progress bar shows remaining cards
- **Queue Management**: Difficult cards are re-queued for same session

### 2. Spaced Repetition Algorithm

- **Dynamic Intervals**: Review intervals increase with correct answers
  - First review: Next day
  - Subsequent reviews: 3, 7, 14, 30 days (adjusts based on performance)
- **Mastery Detection**: 3+ attempts with 80%+ accuracy = mastered
- **Smart Scheduling**: Only shows non-mastered cards due today by default
- **Optional Review**: Users can practice mastered cards on demand

### 3. Progress Tracking

- **Per-Word Statistics**: Tracks correct/total attempts for each vocabulary item
- **Session Tracking**: Records daily study statistics
- **Mastery Levels**: Visual indicators for mastered, learning, struggling, not started
- **Lesson Progress**: Progress bars for each lesson
- **Activity History**: Last study date, total reviews, study streak

### 4. Multi-Device Support

- **Device ID**: Unique identifier stored in browser localStorage
- **Export/Import**: JSON-based progress backup and restoration
- **Automatic Sync**: Background sync every 5 minutes when active
- **No Login**: Privacy-focused, no personal data collected

### 5. Vocabulary Management

- **Organized Lessons**: Currently Lessons 1-8 (67 vocabulary items)
- **Rich Content**: Korean, romanization, English meaning, category
- **Audio Support**: Web Speech API for Korean pronunciation
- **Collapsible Lessons**: Expandable vocabulary browser by lesson

### 6. Statistics Dashboard

- **Overall Stats**: Total words, words studied, mastered, accuracy
- **Review Schedule**: Due today, tomorrow, this week
- **Learning Breakdown**: Mastered, learning, struggling, not started
- **Recent Activity**: Last study session, daily/weekly reviews
- **Lesson Progress**: Per-lesson completion tracking

---

## Technical Architecture

### Technology Stack

**Frontend:**
- Pure HTML5 (no framework)
- Vanilla JavaScript (ES6+)
- CSS3 with responsive design
- Web Speech API for audio

**Backend:**
- PHP 7.4+
- RESTful API design
- PDO for database access

**Database:**
- MySQL 5.7+
- UTF-8MB4 for Korean character support
- InnoDB engine for foreign keys

**Hosting Requirements:**
- Web server with PHP support
- MySQL database
- HTTPS recommended (not required)

### System Architecture

```
┌─────────────────────────────────────────┐
│         Frontend (SPA)                  │
│  ┌─────────────────────────────────┐   │
│  │  index.html                     │   │
│  │  - Flashcard UI                 │   │
│  │  - Progress Display             │   │
│  │  - Statistics Dashboard         │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  js/api-client.js               │   │
│  │  - HTTP requests                │   │
│  │  - Device ID management         │   │
│  │  - Response handling            │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                   ↕ HTTP/JSON
┌─────────────────────────────────────────┐
│         Backend (PHP REST API)          │
│  ┌─────────────────────────────────┐   │
│  │  api/lessons.php                │   │
│  │  - GET lessons                  │   │
│  │  - GET vocabulary               │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  api/progress.php               │   │
│  │  - GET progress                 │   │
│  │  - GET due cards                │   │
│  │  - POST update progress         │   │
│  │  - PUT batch import             │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  api/config.php                 │   │
│  │  - Database connection          │   │
│  │  - Helper functions             │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                   ↕ PDO
┌─────────────────────────────────────────┐
│         Database (MySQL)                │
│  ┌─────────────────────────────────┐   │
│  │  lessons                        │   │
│  │  - Lesson metadata              │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  vocabulary                     │   │
│  │  - Korean words/phrases         │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  user_progress                  │   │
│  │  - Per-word tracking            │   │
│  │  - Spaced repetition data       │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  session_stats                  │   │
│  │  - Daily study statistics       │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### File Structure

```
Korean_Review_System/
├── README.md                    # User documentation
├── Claude.md                    # This file - AI assistant guide
├── index.html                   # Main application interface
├── bibimbap.ico                 # Favicon
│
├── js/
│   └── api-client.js           # API client library
│
├── api/                        # Backend REST API
│   ├── config.php              # Database configuration
│   ├── lessons.php             # Lesson/vocabulary endpoints
│   ├── progress.php            # Progress tracking endpoints
│   ├── test.php                # API connectivity test
│   ├── diagnostic.php          # Debugging tool
│   └── reset-schedule.php      # Admin utility
│
├── database/                   # Database files
│   ├── schema.sql              # Table definitions
│   ├── initial-data.sql        # Lessons 1-8 vocabulary
│   ├── add-spaced-repetition.sql   # SR algorithm upgrade
│   └── add-lesson-template.sql     # Template for new lessons
│
└── test-*.html                 # Diagnostic tools
```

---

## Project Requirements

### Functional Requirements

1. **Flashcard System**
   - Display Korean word on front
   - Reveal romanization + meaning on flip
   - Support audio pronunciation
   - Track user responses (know/difficult)

2. **Spaced Repetition**
   - Calculate next review dates based on performance
   - Only show due cards by default
   - Adjust intervals dynamically
   - Detect mastery (3+ attempts, 80%+ accuracy)

3. **Progress Persistence**
   - Save every card review to database
   - Associate progress with device ID
   - Allow export as JSON
   - Allow import from JSON

4. **Statistics & Reporting**
   - Show overall progress (mastered/learning/struggling)
   - Display review schedule (due today/tomorrow/week)
   - Track accuracy percentage
   - Show per-lesson progress

5. **Vocabulary Management**
   - Browse all vocabulary by lesson
   - Play audio for any word
   - View romanization hints
   - See category/context

### Non-Functional Requirements

1. **Performance**
   - Page load < 2 seconds
   - API response < 500ms
   - Smooth animations (60fps)

2. **Usability**
   - Works on mobile and desktop
   - No login required
   - Intuitive interface
   - Clear visual feedback

3. **Reliability**
   - Automatic progress saving
   - Error handling with user-friendly messages
   - Data validation on client and server

4. **Security**
   - SQL injection prevention (prepared statements)
   - XSS prevention (output escaping)
   - CORS headers configured
   - Device ID validation

5. **Scalability**
   - Support for 60 lessons (planned)
   - Multiple concurrent users
   - Database indexing for performance

---

## Technical Direction

### Design Principles

1. **Simplicity First**: Avoid over-engineering, use vanilla JS/HTML/CSS when possible
2. **Progressive Enhancement**: Core functionality works everywhere, enhancements (audio) are optional
3. **Data Integrity**: Database is source of truth, client-side is for display only
4. **Privacy-Focused**: No personal data collection, device IDs are anonymous
5. **Offline-Ready**: Progress saves automatically, works during temporary disconnections

### Technology Choices & Rationale

**Why No Frontend Framework?**
- Project scope is manageable with vanilla JavaScript
- Reduces bundle size and complexity
- Easier deployment (no build step)
- Better performance on low-end devices

**Why PHP?**
- Widely supported hosting
- Simple deployment model
- Good performance for this use case
- PDO provides excellent database security

**Why MySQL?**
- Excellent UTF-8MB4 support for Korean characters
- Foreign key constraints ensure data integrity
- Well-understood and widely available
- Good query performance with proper indexing

**Why Device-Based Auth?**
- Eliminates friction of account creation
- No password security concerns
- Privacy-focused (no email/personal data)
- Simpler codebase

### Code Style & Standards

**PHP:**
- Use prepared statements for ALL database queries
- Follow PSR-12 coding standard
- Use meaningful variable names
- Document complex logic with comments
- Always send JSON responses with success/data/message structure

**JavaScript:**
- Use ES6+ features (const/let, arrow functions, async/await)
- Follow Airbnb JavaScript style guide
- Use descriptive function names
- Add JSDoc comments for complex functions
- Handle errors gracefully with user-friendly messages

**SQL:**
- Use UPPERCASE for SQL keywords
- Indent for readability
- Always specify column names (no SELECT *)
- Use meaningful table/column names
- Add indexes for frequently queried columns

**HTML/CSS:**
- Semantic HTML5 elements
- Mobile-first responsive design
- Use CSS Grid/Flexbox for layouts
- BEM naming convention for CSS classes (optional but preferred)
- Accessibility: proper ARIA labels, keyboard navigation

---

## Database Schema

### Tables Overview

#### `lessons`
Stores lesson metadata and organization.

| Column | Type | Description |
|--------|------|-------------|
| id | INT PRIMARY KEY | Lesson number (1-60) |
| title | VARCHAR(200) | Lesson title (e.g., "Greetings & Introduction") |
| week | INT | Week in curriculum |
| phase | INT | Learning phase (1-4) |
| description | TEXT | Lesson overview |
| created_at | TIMESTAMP | Creation timestamp |

#### `vocabulary`
Stores all Korean words and phrases.

| Column | Type | Description |
|--------|------|-------------|
| id | INT PRIMARY KEY AUTO_INCREMENT | Unique word ID |
| lesson_id | INT | Foreign key to lessons |
| korean | VARCHAR(200) | Korean text (안녕하세요) |
| romanization | VARCHAR(200) | Romanized pronunciation (annyeonghaseyo) |
| meaning | VARCHAR(300) | English translation |
| category | VARCHAR(50) | Word type (noun, verb, phrase, etc.) |
| hint | TEXT | Additional context |
| example_sentence | TEXT | Usage example |
| created_at | TIMESTAMP | Creation timestamp |

**Indexes:** lesson_id, category

#### `user_progress`
Tracks learning progress per word per device.

| Column | Type | Description |
|--------|------|-------------|
| id | INT PRIMARY KEY AUTO_INCREMENT | Unique record ID |
| device_id | VARCHAR(100) | Device identifier |
| word_id | INT | Foreign key to vocabulary |
| correct_count | INT | Number of correct answers |
| total_attempts | INT | Total review attempts |
| mastered | BOOLEAN | Mastery status (80%+ accuracy, 3+ attempts) |
| last_reviewed | TIMESTAMP | Last review date |
| next_review_date | DATE | Calculated next review date |
| review_interval_days | INT | Current interval (1, 3, 7, 14, 30) |
| created_at | TIMESTAMP | First review date |
| updated_at | TIMESTAMP | Last update |

**Unique Key:** (device_id, word_id)
**Indexes:** device_id, mastered, last_reviewed

#### `session_stats`
Tracks daily study statistics.

| Column | Type | Description |
|--------|------|-------------|
| id | INT PRIMARY KEY AUTO_INCREMENT | Unique record ID |
| device_id | VARCHAR(100) | Device identifier |
| study_date | DATE | Date of study session |
| cards_reviewed | INT | Cards reviewed that day |
| correct_answers | INT | Correct answers |
| accuracy | DECIMAL(5,2) | Daily accuracy percentage |
| study_time_minutes | INT | Study duration (future use) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update |

**Unique Key:** (device_id, study_date)
**Indexes:** device_id, study_date

---

## API Reference

### Base URL
```
/korean/api/
```

### Authentication
All requests require device ID sent via:
- Header: `X-Device-ID: device_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Query parameter: `?device_id=device_xxx...`
- Request body: `{"device_id": "device_xxx..."}`

### Endpoints

#### Lessons API (`/api/lessons.php`)

**GET /lessons.php?action=list**
- Returns all lessons
- Response: `{success: true, data: [{id, title, week, phase, description}]}`

**GET /lessons.php?action=detail&lesson_id={id}**
- Returns lesson with vocabulary
- Response: `{success: true, data: {lesson: {...}, vocabulary: [...]}}`

**GET /lessons.php?action=vocabulary**
- Returns all vocabulary
- Response: `{success: true, data: [{id, korean, romanization, meaning, ...}]}`

**GET /lessons.php?action=vocabulary_by_lesson&lesson_id={id}**
- Returns vocabulary for specific lesson
- Response: `{success: true, data: [...]}`

#### Progress API (`/api/progress.php`)

**GET /progress.php**
- Returns user progress for all words
- Response: `{success: true, data: [{word_id, correct_count, total_attempts, mastered, ...}]}`

**GET /progress.php?action=stats**
- Returns statistics summary
- Response: `{success: true, data: {due_today, due_tomorrow, due_this_week, words_mastered, ...}}`

**GET /progress.php?action=due_cards**
- Returns cards due for review today (non-mastered only)
- Response: `{success: true, data: [{word_id, korean, meaning, romanization, next_review_date, ...}]}`

**POST /progress.php**
- Updates progress for single word
- Body: `{word_id: 1, is_correct: true, device_id: "device_xxx"}`
- Response: `{success: true, message: "Progress updated", data: {next_review_date, ...}}`

**PUT /progress.php**
- Batch update progress (for import)
- Body: `{progress: {word_id: {correct, total, mastered, lastReview}}, device_id: "device_xxx"}`
- Response: `{success: true, message: "Progress imported"}`

### Error Handling

All endpoints return consistent error format:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Technical details (optional)"
}
```

---

## Development Guidelines

### When Adding New Features

1. **Update the Database Schema**
   - Add SQL migration file to `/database/`
   - Document changes in this file
   - Test with fresh database install

2. **Implement Backend API**
   - Add endpoint to relevant PHP file
   - Use prepared statements
   - Validate all inputs
   - Test with diagnostic tools

3. **Update Frontend**
   - Add UI in `index.html`
   - Add API call in `js/api-client.js` if needed
   - Update statistics display if relevant
   - Test on mobile and desktop

4. **Update Documentation**
   - Update README.md for users
   - Update Claude.md (this file) for AI assistants
   - Add comments to complex code

### Common Development Tasks

**Adding a New Lesson:**
1. Use `/database/add-lesson-template.sql` as template
2. Update lesson metadata in `lessons` table
3. Add vocabulary to `vocabulary` table
4. Test by viewing in Vocabulary tab

**Modifying Spaced Repetition Algorithm:**
1. Edit calculation logic in `/api/progress.php`
2. Update `calculateNextReviewDate()` function
3. Test with `/api/reset-schedule.php` to reset intervals
4. Monitor `next_review_date` and `review_interval_days` columns

**Adding Statistics:**
1. Create SQL query in `/api/progress.php`
2. Add to `action=stats` endpoint
3. Update frontend to display in Settings tab
4. Add to `updateOverallStatistics()` function in `index.html`

**Debugging Issues:**
1. Check browser console for JavaScript errors
2. Use `/api/diagnostic.php` to check database state
3. Use `/api/test.php` to verify API connectivity
4. Check PHP error logs on server
5. Use `test-database-connection.html` for connection issues

### Testing Checklist

Before committing changes:
- [ ] Test on Chrome/Firefox/Safari
- [ ] Test on mobile device or responsive mode
- [ ] Verify database queries work with test data
- [ ] Check for JavaScript errors in console
- [ ] Verify API returns proper JSON
- [ ] Test export/import functionality
- [ ] Check progress saves correctly
- [ ] Verify spaced repetition scheduling works
- [ ] Test with multiple device IDs

---

## Future Roadmap

### Planned Features

**Phase 1: Content Expansion** (Current Priority)
- Complete Lessons 9-60 vocabulary
- Add more example sentences
- Include audio recordings (native speakers)

**Phase 2: Enhanced Learning**
- Pronunciation recording & comparison
- Writing practice (draw Korean characters)
- Listening comprehension exercises
- Conversation practice scenarios

**Phase 3: Gamification**
- Achievement system (badges, milestones)
- Daily streak tracking
- Leaderboards (optional, anonymous)
- Challenge modes (speed review, accuracy challenge)

**Phase 4: Social Features**
- Study groups (share progress codes)
- Shared vocabulary decks
- Community-contributed content

**Phase 5: Advanced Features**
- Automatic device sync (server-side session codes)
- Korean keyboard input practice
- Integration with Korean dictionary API
- Sentence builder practice
- Grammar explanations

**Phase 6: Mobile App**
- Native iOS app (Swift)
- Native Android app (Kotlin)
- Offline mode with local database
- Push notifications for review reminders

### Technical Debt to Address

1. **Frontend Framework Migration** (if project grows significantly)
   - Consider Vue.js or React for better state management
   - Only if complexity justifies the overhead

2. **API Authentication** (if adding social features)
   - Implement JWT tokens
   - Add user account system
   - Migrate device IDs to user accounts

3. **Performance Optimization**
   - Add Redis caching for vocabulary lookups
   - Implement API response caching
   - Optimize database queries with better indexing

4. **Testing Infrastructure**
   - Add PHPUnit tests for backend
   - Add Jest tests for frontend
   - Set up CI/CD pipeline

5. **Accessibility Improvements**
   - Full keyboard navigation
   - Screen reader optimization
   - High contrast mode
   - Font size adjustment

---

## Working with AI Assistants

### Context for Claude/AI Assistants

When working on this project:

1. **Always prioritize data integrity** - The database is the source of truth
2. **Use prepared statements** - Never concatenate SQL queries
3. **Maintain backward compatibility** - Consider existing user data
4. **Test spaced repetition logic carefully** - It's the core of the learning system
5. **Keep it simple** - Avoid over-engineering solutions

### Common Requests & How to Handle Them

**"Add a new feature"**
- Check if it fits the project philosophy (simplicity, privacy-focused)
- Consider impact on database schema
- Ensure mobile compatibility
- Update both frontend and backend

**"Fix a bug"**
- First understand the root cause
- Check if it's client-side (JS) or server-side (PHP)
- Verify fix doesn't break existing functionality
- Test with real user scenarios

**"Optimize performance"**
- Profile first, optimize second
- Focus on database queries (biggest bottleneck)
- Consider caching for vocabulary lookups
- Don't sacrifice code clarity for marginal gains

**"Add a new lesson"**
- Use the template in `/database/add-lesson-template.sql`
- Ensure Korean text is properly encoded (UTF-8MB4)
- Test romanization accuracy
- Verify translations with native speaker if possible

---

## Project Philosophy

### Core Values

1. **Learning First**: Every decision prioritizes effective learning over fancy features
2. **Respect User Time**: Fast, efficient, no unnecessary clicks or distractions
3. **Privacy Matters**: No tracking, no accounts (unless user wants them), no data selling
4. **Accessible to All**: Works on any device, any browser, any connection speed
5. **Evidence-Based**: Use proven learning science (spaced repetition, active recall)

### What This Project Is NOT

- Not a comprehensive Korean language course (no grammar deep-dives)
- Not a social network for language learners
- Not a monetization platform (no ads, no paid tiers)
- Not a replacement for immersion or conversation practice
- Not focused on reading/writing Korean (romanization is primary)

### What This Project IS

- A focused vocabulary building tool
- A practice companion for conversational Korean
- A demonstration of spaced repetition effectiveness
- A privacy-respecting learning platform
- A simple, maintainable codebase

---

## Getting Help

### For Developers

- Read `README.md` for setup instructions
- Use `/api/diagnostic.php` for debugging
- Check browser console for frontend errors
- Review this file for architecture decisions

### For AI Assistants

- This file contains complete project context
- Refer to API Reference section for endpoint details
- Check Database Schema for data structure
- Follow Development Guidelines for best practices

### For Users

- See `README.md` for user documentation
- Use Settings tab for export/import help
- Check `/api/test.php` for connectivity issues

---

## Changelog

### Version 1.0 (Current)
- Lessons 1-8 with 67 vocabulary items
- Spaced repetition algorithm implemented
- Full statistics dashboard
- Export/import functionality
- Multi-device support via device IDs
- Responsive mobile design
- Web Speech API audio support

### Planned for Version 2.0
- Lessons 9-20 content
- Enhanced statistics visualization
- Native audio recordings
- Improved mobile UI
- Performance optimizations

---

**Document Version:** 1.0
**Last Updated:** 2025-12-27
**Maintainer:** Project Author
**For:** AI Assistants (Claude, etc.)

---

*This document is designed to give AI assistants comprehensive context about the Korean Review System project, enabling them to provide accurate, contextually-appropriate assistance for development, debugging, and feature additions.*
