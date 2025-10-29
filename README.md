# PenPenny - Smart Personal Finance & Expense Tracker

A comprehensive Flutter app for tracking personal expenses and budgets with advanced analytics, built following clean architecture principles.

## ✨ Features

### Core Features
- **Dashboard Analytics**: Interactive pie charts showing expenses by category
- **Transaction Management**: Add, edit, delete transactions with categories
- **Budget Management**: Set monthly budgets with visual alerts and warnings
- **Account Management**: Multiple accounts with balance tracking
- **Offline Storage**: SQLite database for offline access
- **Responsive Design**: Optimized for mobile screens

### Advanced Features
- **Swipe-to-Delete**: Intuitive swipe gestures with undo functionality
- **Budget Alerts**: Color-coded warnings for over-budget categories
- **Dark Mode**: Complete theme system with system/light/dark modes
- **CSV Export**: Export all transactions to CSV format
- **Smooth Animations**: Polished UI with chart and transaction animations
- **Recent Transactions**: Limited display of last 10 transactions

## 🏗️ Architecture

Built using **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                   # Shared utilities and configurations
├── data/                   # Data layer (repositories, models, datasources)
├── domain/                 # Business logic (entities, use cases)
└── presentation/           # UI layer (screens, widgets, BLoC)
```

### State Management
- **BLoC Pattern**: Professional state management throughout
- **Event-Driven**: Reactive UI updates with proper error handling
- **Dependency Injection**: Clean DI setup with GetIt

### Data Persistence
- **SQLite**: Robust local database with migrations
- **Repository Pattern**: Clean data access abstraction
- **Offline-First**: Full functionality without internet

## 🧪 Testing

Comprehensive test suite with **34 passing tests**:

### Unit Tests (11 tests)
- Payment CRUD operations
- Entity behavior and validation
- Repository pattern testing
- Error handling scenarios

### Widget Tests (15 tests)
- Dashboard component logic
- Budget calculation algorithms
- Transaction filtering and limiting
- Swipe-to-delete functionality
- Entity relationships

### Integration Tests (8 tests)
- App settings and theme management
- Material Design integration
- Cross-component functionality

**Test Coverage**: Core business logic, UI components, and user interactions

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x+
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd penpenny
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

### First-Time Setup
- App will show onboarding screen
- Set username and preferred currency
- Default account and categories will be created automatically

## 📱 Screenshots

### Dashboard
- Current balance display (Income - Expenses)
- Interactive expense chart by category
- Budget alerts with color-coded warnings
- Recent transactions list

### Features
- **Swipe-to-Delete**: Swipe left on transactions with confirmation
- **Dark Mode**: Toggle between light/dark/system themes
- **Budget Alerts**: Visual warnings when approaching limits
- **CSV Export**: Export transaction history

## 🛠️ Technical Implementation

### Key Technologies
- **Flutter 3.x**: Cross-platform mobile framework
- **BLoC**: State management with flutter_bloc
- **SQLite**: Local database with sqflite
- **fl_chart**: Interactive charts and visualizations
- **GetIt**: Dependency injection
- **Mockito**: Testing with mocks

### Architecture Highlights
- **Clean Architecture**: Domain-driven design
- **SOLID Principles**: Maintainable and testable code
- **Repository Pattern**: Data access abstraction
- **Event-Driven**: Reactive programming with BLoC

### Performance Optimizations
- **Lazy Loading**: Efficient data loading
- **Widget Optimization**: Minimal rebuilds
- **Database Indexing**: Fast query performance
- **Memory Management**: Proper resource cleanup

## 📊 Features Breakdown

### Dashboard Analytics ✅
- Animated pie chart showing expense breakdown
- Category-wise spending visualization
- Real-time balance calculations
- Monthly budget progress tracking

### Transaction Management ✅
- Add income/expense transactions
- Edit existing transactions
- Delete with swipe gesture and confirmation
- Category and account assignment
- Date and time selection

### Budget Management ✅
- Set monthly budgets per category
- Visual progress indicators
- Color-coded alerts (70%+ usage)
- Over-budget highlighting

### User Experience ✅
- Intuitive swipe gestures
- Smooth animations and transitions
- Dark mode support
- Responsive design
- Input validation and error handling

## 🧩 Widget Architecture

### Screen-wise Organization
```
lib/presentation/screens/home/widgets/
├── account_slider.dart          # Account balance cards
├── budget_alerts.dart           # Budget warning system
├── dismissible_payment_item.dart # Swipe-to-delete transactions
├── expense_chart.dart           # Interactive pie chart
├── income_expense_cards.dart    # Summary cards
├── payment_list_item.dart       # Transaction list item
└── recent_transactions.dart     # Limited transaction display
```

### Common Widgets
```
lib/presentation/widgets/common/
├── export_csv_button.dart       # CSV export functionality
└── theme_mode_toggle.dart       # Dark mode toggle
```

## 📈 Future Enhancements

### Planned Features
- **Cloud Sync**: Multi-device synchronization
- **Advanced Analytics**: Spending trends and insights
- **Bill Reminders**: Recurring payment notifications
- **Multi-Currency**: Support for multiple currencies
- **Data Import**: Import from bank statements

### Technical Improvements
- **Performance**: Further optimization for large datasets
- **Accessibility**: Enhanced screen reader support
- **Localization**: Multi-language support
- **Security**: Enhanced data encryption

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Write tests for new features
- Use conventional commit messages
- Maintain clean architecture principles

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library for state management
- fl_chart for beautiful visualizations
- SQLite for reliable data persistence

---

**PenPenny** - Take control of your finances with smart expense tracking and budgeting! 💰📊