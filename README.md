# K. Holiday Maps CRM

A modern Travel CRM system built with Flutter and Firebase, featuring a clean architecture and responsive design.

## Features

- **Authentication & Authorization**
  - Email/password authentication
  - Role-based access control (Admin, Manager, Team Leader, Sales Agent)
  - Session management with auto-logout

- **Customer Management**
  - Comprehensive customer profiles
  - Real-time search and filtering
  - Assignment to teams/agents
  - Note management with privacy controls
  - Duplicate detection
  - Soft deletion support

- **Modern UI/UX**
  - Responsive design (desktop & mobile)
  - Dark/light theme support
  - Material Design 3
  - Custom minimalist theme
  - Role-based UI adaptations

## Tech Stack

- **Frontend**: Flutter 3.29.3
- **State Management**: GetX
- **Backend**: Firebase
  - Authentication
  - Firestore
  - Storage
  - Cloud Messaging
- **Architecture**: Clean Architecture with MVVM pattern

## Project Structure

```
lib/
├── config/               # App configuration and theme
├── controllers/          # GetX controllers
├── middleware/          # Route guards and middleware
├── models/             # Data models
├── routes/             # Route definitions
├── services/           # Business logic and Firebase integration
└── views/              # UI components
    ├── auth/           # Authentication views
    ├── customers/      # Customer management
    ├── dashboard/      # Main dashboard
    └── shared/         # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter 3.29.3 or higher
- Firebase project with:
  - Authentication enabled
  - Firestore database
  - Storage bucket
  - Cloud Messaging configured

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/travel-crm.git
cd travel-crm
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Firebase configuration to `lib/main.dart`
   - Enable Email/Password authentication
   - Set up Firestore security rules

4. Run the app:
```bash
flutter run
```

### Firebase Configuration

Replace the Firebase configuration in `lib/main.dart` with your own:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  ),
);
```

## Security

- All routes are protected with role-based middleware
- Firestore security rules enforce access control
- Input validation on all forms
- Secure file upload handling
- Session timeout management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Material Design for the design system
- Firebase for backend services
- GetX for state management
- Flutter team for the amazing framework
