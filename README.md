# MindJourney - Flutter Blog Platform

A modern mental health and wellbeing blog application built with Flutter and Supabase. Features a comprehensive admin panel with rich text editing capabilities.

## Overview

MindJourney is a cross-platform blog application focused on mental health content. It provides both a user-facing blog interface and a powerful admin dashboard for content management.

## Features

### User Features
- Responsive blog interface with article browsing
- Article reading with markdown rendering
- Comment system and article likes
- Daily inspiration content
- About page with author information
- Light and dark theme support

### Admin Features
- Rich text editor with comprehensive formatting toolbar
- Content management for blog posts and pages
- Daily content management (word/thought of the day)
- Live preview while editing
- Post categorization and publication controls

## Tech Stack

- **Frontend**: Flutter 3.22.0, Dart 3.4.0
- **Backend**: Supabase (PostgreSQL, Authentication, Storage)
- **State Management**: Provider
- **Navigation**: Go Router
- **UI Components**: Material 3, flutter_markdown
- **Image Handling**: cached_network_image

## Getting Started

### Prerequisites
- Flutter SDK 3.22.0 or higher
- Dart 3.4.0 or higher
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/akshat2474/pages
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase:
Create a `.env` file:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Set up database tables:
Run the SQL migrations in `/supabase/migrations/` to create:
- `posts` table for blog articles
- `comments` table for user comments
- `daily_content` table for inspiration content
- `about` table for about page content

5. Run the application:
```bash
flutter run -d chrome  
flutter run           
```

## Project Structure

```
lib/
├── config/          
├── models/         
├── screens/         
│   ├── home/     
│   ├── admin/       
│   ├── post/       
│   └── about/       
├── services/         
├── widgets/         
│   ├── rich_text_editor.dart
│   ├── markdown_preview.dart
│   └── animated_widgets.dart
└── utils/         
```

## Usage

### For Readers
- Visit the home page to browse articles
- Click on articles to read full content
- Leave comments and like articles
- Check daily inspiration content

### For Admins
- Access `/admin` to reach the admin dashboard
- Use the rich text editor to create and edit posts
- Toggle between editor and preview modes
- Manage categories and publication status
- Update about page content and daily inspiration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

