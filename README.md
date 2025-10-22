# 🇰🇷 Korean Learning System

A comprehensive web-based Korean language learning system with flashcards, progress tracking, and multi-device synchronization.

## 📚 Features

- **Flashcard System**: Spaced repetition learning with visual feedback
- **Progress Tracking**: Automatic tracking of mastered words and accuracy
- **Multi-Device Sync**: Access your progress from any device
- **Vocabulary Management**: Organized by lessons (currently Lessons 1-8)
- **Practice Modes**: Flashcards, listening practice, and role-play scenarios
- **Statistics Dashboard**: Track your learning journey with detailed stats
- **Export/Import**: Backup and restore your progress
- **Audio Support**: Text-to-speech pronunciation for all Korean words

## 🏗️ Architecture

### Backend (PHP + MySQL)
- RESTful API endpoints
- Device-based authentication (no login required)
- Progress persistence across devices
- Statistics tracking

### Frontend (HTML + JavaScript)
- Single-page application
- Responsive design
- Local storage for offline capability
- Dynamic content loading from API

## 📁 File Structure

```
korean-learning/
├── README.md                   # This file
├── SETUP.md                    # Deployment instructions
│
├── database/                   # Database files
│   ├── schema.sql             # Database structure
│   └── initial-data.sql       # Lessons 1-8 vocabulary
│
├── api/                        # Backend API (PHP)
│   ├── config.php             # Database configuration
│   ├── lessons.php            # Lessons & vocabulary endpoints
│   ├── progress.php           # Progress tracking endpoints
│   └── test.php               # API connection test
│
└── public/                     # Frontend application
    ├── index.html             # Main application page
    ├── css/
    │   └── styles.css         # Application styles
    └── js/
        ├── api-client.js      # API communication layer
        ├── app.js             # Main application logic
        └── flashcards.js      # Flashcard functionality
```

## 🗄️ Database Schema

### Tables

1. **lessons**: Lesson metadata and organization
2. **vocabulary**: All Korean words/phrases with translations
3. **user_progress**: Individual word mastery tracking per device
4. **session_stats**: Daily study statistics

## 🚀 Quick Start

### Prerequisites
- Web hosting with PHP 7.4+ and MySQL 5.7+
- FTP/SFTP access
- Modern web browser

### Installation

1. **Clone or download** this project
2. **Create MySQL database** on your hosting
3. **Import database files**:
   - Import `database/schema.sql`
   - Import `database/initial-data.sql`
4. **Configure** `api/config.php` with your database credentials
5. **Upload files** to your web server
6. **Test API**: Visit `yoursite.com/api/test.php`
7. **Access app**: Visit `yoursite.com/public/index.html`

See **SETUP.md** for detailed step-by-step instructions.

## 📖 Current Content

### Lessons 1-8 (67 vocabulary items)

- **Lesson 1**: Greetings & Introduction (4 words)
- **Lesson 2**: Where Are You From? (5 words)
- **Lesson 3**: Polite Expressions (4 words)
- **Lesson 4**: Yes/No and Basic Responses (3 words)
- **Lesson 6**: What Do You Do? (3 words)
- **Lesson 7**: Family Members (11 words)
- **Lesson 8**: Age and Numbers (21 words)

### Planned Expansion
Lessons 9-60 covering:
- Daily activities and routines
- Places and directions
- Food and dining
- Shopping and numbers
- Past, present, and future tenses
- Expressing feelings and opinions
- Natural conversation patterns

## 🔧 API Endpoints

### Lessons API (`/api/lessons.php`)
- `GET ?action=list` - Get all lessons
- `GET ?action=detail&lesson_id={id}` - Get lesson with vocabulary
- `GET ?action=vocabulary` - Get all vocabulary
- `GET ?action=vocabulary_by_lesson&lesson_id={id}` - Get lesson vocabulary

### Progress API (`/api/progress.php`)
- `GET` - Get user progress
- `GET ?action=stats` - Get statistics
- `POST` - Update single word progress
- `PUT` - Batch update progress

All endpoints require `X-Device-ID` header or `device_id` parameter.

## 💾 Data Persistence

### Device ID
Each device automatically generates a unique ID stored in browser's local storage. This ID is used to track progress across sessions without requiring user accounts.

### Progress Tracking
- **Correct/Total Attempts**: Tracks every flashcard review
- **Mastery Status**: Word is "mastered" after 3+ attempts with 80%+ accuracy
- **Last Reviewed**: Timestamp of most recent practice
- **Daily Stats**: Cards reviewed, accuracy percentage

### Export/Import
Users can export progress as JSON and import on other devices for manual synchronization.

## 🎨 Customization

### Adding New Vocabulary

1. **Via phpMyAdmin**:
   ```sql
   INSERT INTO vocabulary (lesson_id, korean, romanization, meaning, category)
   VALUES (9, '새 단어', 'sae daneo', 'new word', 'noun');
   ```

2. **Via SQL file**: Create new lesson data files following the pattern in `initial-data.sql`

### Styling
Edit `/public/css/styles.css` to customize colors, fonts, and layout.

### Adding New Lessons
1. Add lesson metadata to `lessons` table
2. Add vocabulary to `vocabulary` table
3. Update course outline if needed

## 🔐 Security Notes

- Device IDs are not cryptographically secure
- No personal information is collected
- CORS is open (`Access-Control-Allow-Origin: *`)
- For production, consider:
  - Implementing proper user authentication
  - Restricting CORS to your domain
  - Using HTTPS
  - Rate limiting API endpoints

## 📱 Browser Compatibility

- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- Mobile browsers: ✅ Responsive design

**Text-to-Speech**: Uses Web Speech API (browser support varies)

## 🤝 Contributing

To add more lessons or features:

1. Follow the existing database schema
2. Use prepared statements for all queries
3. Maintain consistent coding style
4. Test thoroughly before committing

## 📝 License

This project is provided as-is for educational purposes.

## 🎯 Roadmap

- [ ] Complete Lessons 9-60
- [ ] Add pronunciation recording
- [ ] Implement spaced repetition algorithm
- [ ] Add achievement system
- [ ] Create mobile app version
- [ ] Add social features (study groups)
- [ ] Implement automatic device sync with codes
- [ ] Add Korean keyboard input practice
- [ ] Integrate with Korean dictionary API

## 🙏 Acknowledgments

- Course structure based on practical conversation needs
- Vocabulary curated for UK-based Korean language learners
- Designed for VFX artists and creative professionals

---

**Start your Korean learning journey today!** 화이팅! (Fighting!)
