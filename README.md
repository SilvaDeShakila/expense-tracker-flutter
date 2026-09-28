# Expense Tracker

A modern Flutter expense tracking mobile application built with **Flutter, Dart, Firebase Authentication, and Cloud Firestore**. The application helps users record, manage, search, filter, and analyze their personal expenses through a clean and responsive interface.

## Overview

The Expense Tracker application was developed as a practical Flutter mobile application with a focus on:

* Secure user authentication
* Cloud-based expense management
* Simple and intuitive user experience
* Expense analytics and visual summaries
* Search and filtering
* Responsive light and dark themes
* Firebase-based data storage

## Features

### Authentication

* User registration
* Email and password login
* Email verification
* Password reset
* Secure sign-out
* Authentication state management

### Expense Management

* Add new expenses
* Edit existing expenses
* Delete expenses
* Expense title and amount validation
* Category selection
* Expense date selection
* Optional expense notes
* Expense history

### Search & Filters

* Search expenses by title
* Filter by category
* Filter by month
* Clear individual filters
* Clear all active filters
* Active filter indicators

### Analytics

* Monthly spending summary
* Total expense amount
* Number of expenses
* Top spending category
* Category-based expense chart
* Current vs previous month comparison
* Automatic spending insights

### User Experience

* Material 3 design
* Light mode
* Dark mode
* Loading states
* Empty states
* Error handling
* Responsive layouts
* Expense details view
* Paginated expense history

## Technologies Used

| Technology              | Purpose                         |
| ----------------------- | ------------------------------- |
| Flutter                 | Mobile application framework    |
| Dart                    | Programming language            |
| Firebase Authentication | User authentication             |
| Cloud Firestore         | Cloud database                  |
| Material 3              | Application UI                  |
| fl_chart                | Expense analytics and charts    |
| intl                    | Date and number formatting      |
| Git                     | Version control                 |
| GitHub                  | Source code hosting             |
| VS Code                 | Development environment         |
| Android Studio          | Android development and testing |

## Main Packages

```yaml
firebase_core: 4.15.0
cloud_firestore: 6.10.0
firebase_auth: 6.7.0
intl: 0.20.3
fl_chart: ^1.2.0
flutter_launcher_icons: ^0.14.4
cupertino_icons: ^1.0.8
```

## Firebase Architecture

Each authenticated user has a separate expense collection.

```text
users
└── {userId}
    └── expenses
        ├── {expenseId}
        ├── {expenseId}
        └── {expenseId}
```

Each expense contains:

```text
title
amount
category
date
note
createdAt
```

User-specific Firestore paths are used so that expenses are associated with the authenticated user.

## Application Flow

```text
Register
   ↓
Email Verification
   ↓
Login
   ↓
Home Dashboard
   ↓
Add Expense
   ↓
Manage Expenses
   ├── Edit
   ├── Delete
   ├── Search
   └── Filter
   ↓
Analytics
   ├── Monthly Summary
   ├── Category Chart
   └── Spending Insights
```

## Project Structure

```text
expense_tracker/
│
├── assets/
│
├── lib/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── models/
│   │   └── expense_model.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firebase_service.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── all_expenses_screen.dart
│   │   │
│   │   └── add_expense/
│   │       └── add_expense_screen.dart
│   │
│   ├── widgets/
│   │   ├── category_chip.dart
│   │   ├── empty_state.dart
│   │   ├── expense_card.dart
│   │   ├── expense_chart.dart
│   │   ├── expense_summary_card.dart
│   │   ├── loading_widget.dart
│   │   └── spending_insights_card.dart
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── firebase.json
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
└── README.md
```

## Getting Started

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* VS Code
* Git
* A Firebase project

Check your Flutter installation:

```bash
flutter doctor
```

### Clone the Repository

```bash
git clone https://github.com/SilvaDeShakila/expense-tracker-flutter.git
```

Move into the project directory:

```bash
cd expense-tracker-flutter
```

### Install Dependencies

```bash
flutter pub get
```

### Firebase Configuration

This project uses Firebase Authentication and Cloud Firestore.

Before running the application, make sure the Firebase configuration is correctly connected to your Firebase project.

### Run the Application

For Chrome:

```bash
flutter run -d chrome
```

For a connected Android device:

```bash
flutter devices
```

Then:

```bash
flutter run -d <device-id>
```

## Testing

The application was tested through the following main user flow:

```text
Registration
      ↓
Email Verification
      ↓
Login
      ↓
Add Expense
      ↓
Edit Expense
      ↓
Delete Expense
      ↓
Search
      ↓
Category Filter
      ↓
Month Filter
      ↓
Expense Details
      ↓
Pagination
      ↓
Charts
      ↓
Spending Insights
      ↓
Dark Mode
      ↓
Sign Out
```

## Security

The application uses:

* Firebase Authentication
* User-specific Firestore collections
* Firestore security rules
* Authentication-based access control

Firestore rules restrict users to their own expense data.

> Firebase configuration values required by the client application should not be treated as passwords or database credentials. Sensitive credentials such as private service-account keys must never be committed to the repository.

## AI Tools Used

AI-assisted development tools were used during the development process for:

* Code suggestions
* Debugging assistance
* Firebase configuration guidance
* UI and UX ideas
* Code improvement suggestions
* Documentation support
* Troubleshooting development issues

All generated suggestions were reviewed, modified where necessary, and tested manually during development.

## Internship Requirements

| Requirement              | Status    |
| ------------------------ | --------- |
| Add expenses             | Completed |
| Edit expenses            | Completed |
| Delete expenses          | Completed |
| Expense categories       | Completed |
| Firebase storage         | Completed |
| Monthly total            | Completed |
| Expense history          | Completed |
| Category filtering       | Completed |
| Date/month filtering     | Completed |
| Search                   | Completed |
| Validation               | Completed |
| Loading states           | Completed |
| Empty states             | Completed |
| Error handling           | Completed |
| Expense chart            | Completed |
| Dark mode                | Completed |
| Monthly/category summary | Completed |
| Firebase Authentication  | Completed |

## Screenshots

Screenshots of the application will be added here.

Planned screenshots include:

* Login
* Registration
* Email Verification
* Home Dashboard
* Add Expense
* Expense Details
* Search and Filters
* Expense Analytics
* Spending Insights
* Dark Mode
* All Expenses

## Demo

A short screen recording demonstrating the main application features will be added here.

## Future Improvements

Possible future improvements include:

* Export expenses to PDF/CSV
* Budget management
* Recurring expenses
* More detailed financial reports
* Push notifications
* Advanced spending analytics
* Backup and restore functionality

## Author

**Shakila Chamuditha De Silva**

GitHub: [@SilvaDeShakila](https://github.com/SilvaDeShakila)

---

⭐ If you find this project useful, feel free to explore the repository.
