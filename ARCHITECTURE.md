# 🏗️ Korean Learning System - Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER DEVICES                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Browser 1  │  │   Browser 2  │  │   Mobile     │      │
│  │  (Device A)  │  │  (Device B)  │  │  (Device C)  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         │ Device ID: abc   │ Device ID: xyz   │ Device ID   │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
          │   HTTPS          │   HTTPS          │   HTTPS
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                      IONOS WEB SERVER                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    FRONTEND (Public)                    │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │ │
│  │  │  index.html  │  │     CSS      │  │ JavaScript  │  │ │
│  │  │              │  │   Styles     │  │  ├─ app.js  │  │ │
│  │  │  Main UI     │  │              │  │  └─ api.js  │  │ │
│  │  └──────────────┘  └──────────────┘  └─────────────┘  │ │
│  └────────────────────────────────────────────────────────┘ │
│                              ▲                               │
│                              │                               │
│                              │ API Calls                     │
│                              │ (JSON)                        │
│                              ▼                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                     BACKEND API (PHP)                   │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │ │
│  │  │ lessons.php│  │progress.php│  │  test.php  │       │ │
│  │  │            │  │            │  │            │       │ │
│  │  │ GET vocab  │  │ POST/PUT   │  │ Connection │       │ │
│  │  │ GET lessons│  │ progress   │  │   test     │       │ │
│  │  │            │  │ GET stats  │  │            │       │ │
│  │  └─────┬──────┘  └─────┬──────┘  └────────────┘       │ │
│  │        │               │                                │ │
│  │        └───────┬───────┘                                │ │
│  │                │ config.php (DB connection)             │ │
│  └────────────────┼────────────────────────────────────────┘ │
│                   │                                          │
│                   │ PDO                                      │
│                   │ (Prepared Statements)                    │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                   MySQL DATABASE                        │ │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────┐           │ │
│  │  │ lessons  │  │vocabulary│  │user_progress│           │ │
│  │  │          │  │          │  │             │           │ │
│  │  │ id       │  │ id       │  │ device_id   │           │ │
│  │  │ title    │  │ korean   │  │ word_id     │           │ │
│  │  │ week     │  │ meaning  │  │ correct     │           │ │
│  │  │ phase    │  │ lesson_id│  │ total       │           │ │
│  │  └──────────┘  └──────────┘  │ mastered    │           │ │
│  │                               └────────────┘           │ │
│  │                 ┌──────────────┐                        │ │
│  │                 │session_stats │                        │ │
│  │                 │              │                        │ │
│  │                 │ device_id    │                        │ │
│  │                 │ study_date   │                        │ │
│  │                 │ accuracy     │                        │ │
│  │                 └──────────────┘                        │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow Examples

### 1. Loading Flashcards

```
User Opens Page
      │
      ▼
Frontend generates Device ID (if first visit)
      │
      ▼
JavaScript calls: api.getAllVocabulary()
      │
      ▼
API: GET /api/lessons.php?action=vocabulary&device_id=abc
      │
      ▼
PHP queries database:
  SELECT * FROM vocabulary JOIN lessons...
      │
      ▼
Returns JSON: [{korean: "안녕하세요", meaning: "Hello", ...}, ...]
      │
      ▼
Frontend displays flashcards
```

### 2. Saving Progress

```
User clicks "I know this" on flashcard
      │
      ▼
JavaScript calls: api.updateProgress(wordId, true)
      │
      ▼
API: POST /api/progress.php
  Headers: X-Device-ID: abc
  Body: {word_id: 1, is_correct: true}
      │
      ▼
PHP checks if progress exists for this device+word
      │
      ├─ EXISTS: Update correct_count, total_attempts
      │         Calculate if mastered (80% after 3+ attempts)
      │
      └─ NEW: Insert new progress record
      │
      ▼
PHP also updates daily statistics
      │
      ▼
Returns JSON: {success: true, data: {...}}
      │
      ▼
Frontend updates UI with new stats
```

### 3. Multi-Device Access

```
DEVICE A (first time)
      │
      ▼
Generates Device ID: "device_abc123..."
Saves to localStorage
      │
      ▼
Reviews 10 cards, progress saved with device_abc123

─────────────────────────────────────────

DEVICE B (first time)
      │
      ▼
Generates NEW Device ID: "device_xyz789..."
Saves to localStorage
      │
      ▼
Loads same vocabulary (from database)
But has separate progress (different device_id)
Starts fresh - no cards mastered yet

─────────────────────────────────────────

To sync between devices:
      │
      ▼
Device A: Export progress (downloads JSON)
      │
      ▼
Transfer file to Device B
      │
      ▼
Device B: Import progress (uploads JSON)
      │
      ▼
API converts to progress entries with Device B's ID
```

---

## Component Interactions

### Frontend Components

```
index.html
    ├── Loads: styles.css (UI styling)
    ├── Loads: api-client.js (API communication)
    ├── Loads: app.js (application logic)
    └── Contains: flashcards.js (flashcard functionality)

api-client.js (KoreanLearningAPI class)
    ├── Methods:
    │   ├── getLessons()
    │   ├── getAllVocabulary()
    │   ├── getProgress()
    │   ├── updateProgress(wordId, isCorrect)
    │   ├── getStats()
    │   └── exportProgress()
    │
    └── Automatically handles:
        ├── Device ID generation
        ├── Adding headers to requests
        ├── Error handling
        └── JSON parsing
```

### Backend Components

```
config.php (Foundation)
    ├── Database credentials
    ├── CORS headers
    ├── Helper functions:
    │   ├── getDBConnection()
    │   ├── sendResponse()
    │   ├── getDeviceId()
    │   └── validateDeviceId()
    └── Used by all other PHP files

lessons.php (Read-only)
    ├── GET ?action=list → All lessons
    ├── GET ?action=detail&lesson_id=N → Lesson + vocabulary
    ├── GET ?action=vocabulary → All vocabulary
    └── GET ?action=vocabulary_by_lesson&lesson_id=N → Lesson vocab

progress.php (Read/Write)
    ├── GET → User's progress
    ├── GET ?action=stats → Statistics
    ├── POST → Update single word progress
    └── PUT → Batch update (for import)

test.php (Utility)
    └── GET → Test database connection and show stats
```

---

## Database Schema Relationships

```
┌──────────┐         ┌──────────────┐         ┌───────────────┐
│ lessons  │◄────────│ vocabulary   │◄────────│user_progress  │
│          │ 1 ───┐  │              │ 1 ───┐  │               │
│ id (PK)  │      └──│ lesson_id(FK)│      └──│ word_id (FK)  │
│ title    │         │ id (PK)      │         │ device_id     │
│ week     │         │ korean       │         │ correct_count │
│ phase    │         │ meaning      │         │ total_attempts│
└──────────┘         │ romanization │         │ mastered      │
                     │ category     │         └───────────────┘
                     └──────────────┘
                                              ┌───────────────┐
                                              │session_stats  │
                                              │               │
                                              │ device_id     │
                                              │ study_date    │
                                              │ cards_reviewed│
                                              │ accuracy      │
                                              └───────────────┘
```

**Relationships:**
- One lesson has many vocabulary items (1:N)
- One vocabulary item has many progress records (1:N) - one per device
- Each device has one daily stats record per day

---

## Security Model

### Device Authentication
```
No username/password required
     │
     ▼
Automatic UUID generation on first visit
     │
     ▼
Stored in browser's localStorage
     │
     ▼
Sent with every API request
     │
     ▼
Server validates format (alphanumeric, 10-100 chars)
     │
     ▼
Used to isolate user data
```

**Pros:**
- ✅ No signup friction
- ✅ Immediate use
- ✅ No password management
- ✅ Privacy-friendly (no personal info)

**Cons:**
- ❌ Not cryptographically secure
- ❌ Lost if browser data cleared
- ❌ Requires export/import for device switching

**For Production Enhancement:**
- Add proper user accounts with bcrypt passwords
- Implement JWT token authentication
- Add rate limiting
- Restrict CORS to specific domain

---

## Data Storage Strategy

### Three-Layer Approach

```
Layer 1: Browser (Fast, Temporary)
     └── localStorage: Device ID only
     
Layer 2: Database (Persistent, Authoritative)
     ├── User progress (per device)
     ├── Vocabulary (shared)
     └── Statistics (per device)
     
Layer 3: Export File (Backup, Transfer)
     └── JSON file: Complete progress snapshot
```

**Why this works:**
- Fast loading (API caches appropriately)
- Reliable persistence (database)
- User control (export/import)
- Multi-device capable (separate device IDs)

---

## Performance Characteristics

### Expected Response Times

```
API Endpoint                    Expected Time
────────────────────────────────────────────
/api/test.php                   < 100ms
/api/lessons.php?action=list    < 200ms
/api/lessons.php?action=vocab   < 300ms
/api/progress.php (GET)         < 200ms
/api/progress.php (POST)        < 150ms
```

### Scalability

**Current Capacity:**
- Supports: Hundreds of concurrent users
- Limitations: Shared hosting resources
- Bottleneck: Database connections (typically 10-30)

**Optimization Options:**
- Add caching layer (Redis/Memcached)
- Implement CDN for static assets
- Database query optimization
- Consider serverless for API (if needed)

---

## Error Handling Flow

```
Frontend Request
     │
     ▼
Try API Call
     │
     ├─ Success ─────────────────┐
     │                           │
     └─ Error                    │
          │                      │
          ▼                      │
     Log to console              │
          │                      │
          ▼                      │
     Show user message           │
          │                      ▼
          └────────────────► Continue app
          
API Response includes:
{
    success: true/false,
    message: "Human-readable message",
    data: {...} or null
}
```

---

## Deployment Checklist Reference

```
☐ Database Setup
   ├─ Create database
   ├─ Import schema.sql
   └─ Import initial-data.sql

☐ Backend Setup
   ├─ Upload PHP files
   ├─ Configure config.php
   └─ Test with test.php

☐ Frontend Setup
   ├─ Upload HTML/CSS/JS
   ├─ Update API baseUrl
   └─ Test in browser

☐ Integration Test
   ├─ Load vocabulary
   ├─ Save progress
   ├─ Export/import
   └─ Multi-device test
```

---

## Future Architecture Enhancements

### Phase 1: Current (Device-Based)
- ✅ Simple UUID per device
- ✅ Manual sync via export/import

### Phase 2: Sync Codes
- 📋 Generate 6-digit codes
- 📋 Link devices together
- 📋 Automatic progress sync

### Phase 3: User Accounts
- 📋 Email/password authentication
- 📋 JWT tokens
- 📋 Password reset
- 📋 Multi-device automatic sync

### Phase 4: Real-time
- 📋 WebSockets
- 📋 Live progress updates
- 📋 Collaborative features

---

## Key Design Decisions

### Why PHP + MySQL?
- ✅ Available on IONOS hosting
- ✅ Mature, stable technology
- ✅ Easy to deploy and maintain
- ✅ Good performance for this scale

### Why Device ID vs User Accounts?
- ✅ Lower friction (no signup)
- ✅ Privacy-friendly
- ✅ Simpler implementation
- ✅ Good enough for personal use

### Why localStorage for Device ID?
- ✅ Simple implementation
- ✅ Works offline
- ✅ No cookies needed
- ✅ Persistent across sessions

### Why Separate Progress per Device?
- ✅ Allows independent learning paces
- ✅ Family sharing of one account
- ✅ Testing new learning methods
- ✅ Future: easy to merge if needed

---

This architecture provides a solid foundation that's:
- ✅ Easy to deploy
- ✅ Easy to maintain
- ✅ Ready to scale
- ✅ Ready for enhancements

**Next: Follow QUICK-START.md to deploy!**
