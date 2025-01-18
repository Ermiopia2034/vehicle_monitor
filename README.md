# Vehicle Monitor

A modern Flutter application for real-time vehicle monitoring and fleet management. Built with a focus on clean architecture, modern UI/UX, and scalability for future IoT integration.

## Features

### Current Implementation
- **Modern Dashboard**
  - Real-time vehicle status monitoring
  - Clean, card-based UI with dynamic color themes
  - Dark mode support for better visibility
  - At-a-glance vehicle information display

- **Detailed Vehicle Management**
  - Individual vehicle status pages
  - Real-time updates for:
    - Fuel levels
    - Battery levels
    - Vehicle status (Active/Maintenance/Inactive)
    - Location tracking

- **Firebase Integration**
  - Real-time data synchronization
  - Secure data storage
  - Scalable backend infrastructure

- **State Management**
  - Riverpod for efficient state management
  - Stream-based real-time updates
  - Reactive UI updates

### Technical Stack
- **Frontend**: Flutter/Dart
- **Backend**: Firebase
- **State Management**: Riverpod
- **Architecture**: Clean Architecture with MVVM pattern

## Future Integration Plans

### Bluetooth/OBD2 Integration
The application is designed to be extended with real-time vehicle data through OBD2 devices:

1. **Hardware Integration**
   - OBD2 Bluetooth adapter support
   - Direct connection to vehicle's ECU
   - Real-time data polling

2. **Enhanced Metrics**
   - Engine RPM monitoring
   - Vehicle speed tracking
   - Engine temperature
   - Diagnostic trouble codes (DTCs)
   - Fuel efficiency metrics

3. **Real-time Analytics**
   - Performance tracking
   - Predictive maintenance alerts
   - Fuel consumption analysis
   - Battery health monitoring

4. **Automated Updates**
   - Background data synchronization
   - Automated status updates
   - Push notifications for critical events

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Firebase account
- Android Studio or VS Code
- Git

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vehicle_monitor.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your `google-services.json` to the Android app
   - Add your `GoogleService-Info.plist` to the iOS app

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure
```
lib/
├── main.dart
├── screens/
│   ├── dashboard_screen.dart
│   └── vehicle_details_screen.dart
├── services/
│   └── firebase_service.dart
├── providers/
│   └── vehicle_provider.dart
└── models/
    └── vehicle.dart
```

## Contributing
We welcome contributions! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Flutter Team for the amazing framework
- Firebase for the robust backend
- The open-source community

## Contact
For any inquiries about the project or potential collaborations, please reach out to [Your Contact Information].
