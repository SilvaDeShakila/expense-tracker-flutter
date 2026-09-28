# Expense Tracker

A modern Flutter mobile application for managing personal expenses with Firebase Authentication, Cloud Firestore, search, filters, spending analytics, charts, and dark mode.

---

## Project Overview

**Expense Tracker** is a mobile application developed with Flutter to help users record, manage, and analyze their daily expenses.

The application provides secure user authentication and stores each user's expense data separately in Cloud Firestore. Users can add, edit, delete, search, filter, and review their spending through summaries, charts, and automatic spending insights.

---

## Features

### Authentication

* User registration with email and password
* Email verification
* Secure login and logout
* Password reset through email
* Authentication state management

### Expense Management

* Add new expenses
* Edit existing expenses
* Delete expenses
* Expense title, amount, category, date, and optional note
* Input validation
* Amount formatting with decimal support

### Search & Filtering

* Search expenses by title
* Filter expenses by category
* Filter expenses by month
* Combine search and filters
* Clear individual filters
* Clear all active filters

### Expense Analytics

* Monthly spending total
* Total number of expenses
* Top spending category
* Category-based expense chart
* Current month vs previous month comparison
* Automatic spending insights

### User Experience

* Material 3 interface
* Light and dark themes
* Loading states
* Empty states
* Error handling
* Expense details view
* Expense history with pagination
* Responsive interface

---

## Technologies & Packages Used

| Technology / Package    | Purpose                         |
| ----------------------- | ------------------------------- |
| Flutter                 | Mobile application framework    |
| Dart                    | Programming language            |
| Firebase Authentication | User authentication             |
| Cloud Firestore         | Cloud database                  |
| Material 3              | Application UI design           |
| fl_chart                | Expense charts and analytics    |
| intl                    | Date and number formatting      |
| Git                     | Version control                 |
| GitHub                  | Source code hosting             |
| VS Code                 | Primary development environment |

---

## AI Tools Used

AI tools were used as part of the development process to support implementation, troubleshooting, and documentation. The final application was assembled, configured, tested, and run by the developer.

### ChatGPT

ChatGPT was used throughout the development process to assist with:

* Generating Flutter code for different application features
* Providing terminal commands for project setup, package management, Firebase configuration, and Git operations
* Explaining Flutter and Firebase concepts when needed
* Troubleshooting build errors, runtime issues, and configuration problems
* Assisting with Firebase Authentication and Cloud Firestore integration
* Suggesting UI/UX improvements and reusable component structures
* Supporting the implementation of search, filtering, pagination, charts, and spending insights
* Reviewing and improving code based on encountered issues
* Assisting with validation, error handling, and application flow
* Preparing project documentation and README content

### How AI Supported the Development

AI was used as a development assistant throughout the project. Code suggestions and implementation guidance were used as part of the development workflow, while the developer was responsible for applying the changes, running the required commands, configuring the development environment, testing the application, and resolving issues encountered during implementation.

The application was developed iteratively by implementing features, running and testing them, identifying problems, and making the necessary changes.

AI assistance helped accelerate development and problem-solving while also providing an opportunity to understand and work with Flutter, Firebase, Git, and related development tools.

---

## Project Structure

```text
expense_tracker/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   │
│   ├── models/
│   │   └── expense_model.dart
│   │
│   ├── services/
│   │   ├── firebase_service.dart
│   │   └── auth_service.dart
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
│   │   ├── expense_card.dart
│   │   ├── category_chip.dart
│   │   ├── empty_state.dart
│   │   ├── loading_widget.dart
│   │   ├── expense_chart.dart
│   │   ├── expense_summary_card.dart
│   │   └── spending_insights_card.dart
│   │
│   └── main.dart
│
├── assets/
├── test/
├── android/
├── web/
├── README.md
└── pubspec.yaml
```

---

## Firebase Architecture

The application uses Firebase Authentication for user accounts and Cloud Firestore for storing expense data.

Each authenticated user has a separate expense collection:

```text
users
└── {userId}
    └── expenses
        ├── {expenseId}
        ├── {expenseId}
        └── {expenseId}
```

This structure keeps expenses associated with the authenticated user.

Firestore security rules restrict users to their own user document and expense records.

---

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
   └── View Details
   ↓
Search & Filter
   ↓
Analytics & Charts
   ↓
Spending Insights
   ↓
Dark Mode / Profile
   ↓
Sign Out
```

---

## Getting Started

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Git
* VS Code
* A Firebase project

### 1. Clone the Repository

```bash
git clone https://github.com/SilvaDeShakila/expense-tracker-flutter.git
```

### 2. Open the Project

```bash
cd expense-tracker-flutter
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Create or use a Firebase project and configure Firebase for the Flutter application.

The project uses:

* Firebase Authentication
* Cloud Firestore

Enable **Email/Password Authentication** in Firebase Authentication.

Create the required Firestore database and apply the project's Firestore security rules.

### 5. Run the Application

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

For Chrome:

```bash
flutter run -d chrome
```

For a connected Android device:

```bash
flutter run -d <device-id>
```

---

## Testing

The main functionality was tested through the following flow:

```text
✓ User Registration
✓ Email Verification
✓ User Login
✓ Home Dashboard
✓ Add Expense
✓ Edit Expense
✓ Delete Expense
✓ Expense Details
✓ Search Expenses
✓ Category Filtering
✓ Month Filtering
✓ Combined Filters
✓ Expense Pagination
✓ Monthly Summary
✓ Expense Chart
✓ Spending Insights
✓ Dark Mode
✓ Sign Out
```

The application was tested on a physical Android device and during Flutter development.

---

## Security

The application uses Firebase Authentication to identify users and Firestore Security Rules to control access to user-specific data.

Expense records are stored under the authenticated user's UID:

```text
users/{userId}/expenses/{expenseId}
```

Firestore rules ensure that authenticated users can access only their own expense data.

> Firebase client configuration values such as API keys may appear in Flutter-generated configuration files. These are not treated as database credentials. Access to application data is controlled through Firebase Authentication and Firestore Security Rules.

---

## Screenshots

Screenshots of the application will be added here to demonstrate the main user interface and functionality.

Recommended screenshots:

* Login
* Registration
* Email Verification
* Home Dashboard
* Add Expense
* Expense Details
* Search & Filters
* Analytics
* Dark Mode

---

## Demo

A short screen recording demonstrating the main application features will be provided here.

**Demo Video:** Coming soon

---

## Future Improvements

Possible future enhancements include:

* Budget management
* Expense reminders
* Export expenses as PDF or CSV
* Advanced financial reports
* Recurring expenses
* More detailed category analytics
* Cloud-based backup and restore improvements

---

## Internship Requirements

| Requirement                    | Implementation                             |
| ------------------------------ | ------------------------------------------ |
| Project setup instructions     | Included in Getting Started                |
| Features implemented           | Documented in Features                     |
| Technologies and packages used | Documented in Technologies & Packages Used |
| AI tools used                  | Documented in AI Tools Used                |
| Add expenses                   | Implemented                                |
| Edit expenses                  | Implemented                                |
| Delete expenses                | Implemented                                |
| Expense categories             | Implemented                                |
| Firebase storage               | Cloud Firestore                            |
| Monthly total                  | Implemented                                |
| Expense history                | Implemented                                |
| Search                         | Implemented                                |
| Category filtering             | Implemented                                |
| Date/month filtering           | Implemented                                |
| Validation                     | Implemented                                |
| Loading states                 | Implemented                                |
| Empty states                   | Implemented                                |
| Error handling                 | Implemented                                |
| Expense charts                 | Implemented                                |
| Dark mode                      | Implemented                                |
| Firebase Authentication        | Implemented                                |

---

## Development Approach

The application was developed using a modular Flutter structure with separate layers for:

* Models
* Services
* Screens
* Reusable widgets
* Theme
* Core utilities

This structure helps keep the code organized and makes individual features easier to maintain and extend.

---

## Author

**Shakila Chamuditha De Silva**

Software Engineering / Information Technology Undergraduate

GitHub: **SilvaDeShakila**

---

## License

This project was developed as part of an internship practical assignment and is currently provided for educational and portfolio purposes.
