# Honey Badger AI Gifts - iOS App

Native iOS application for Honey Badger AI Gifts platform built with SwiftUI.

## Overview

This is the iOS client for the Honey Badger AI Gifts application. Users can create accounts, send motivational gift challenges, manage contacts, and interact with the Honey Badger AI coach - all from their iPhone or iPad.

## Tech Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Min iOS Version**: iOS 15.0+
- **Xcode**: 16.0+
- **Architecture**: MVVM with Combine
- **Networking**: URLSession with async/await
- **Data Persistence**: Core Data (minimal), UserDefaults

## Quick Start

### Prerequisites

- macOS with Xcode 16.0 or higher
- iOS Simulator or physical iOS device
- Node.js backend running (see honey-badger-backend repo)

### Installation

1. **Open the project in Xcode:**
   ```bash
   cd honey-badger-ios
   open HoneyBadgerApp.xcodeproj
   ```

2. **Configure backend URL:**
   - Open `HoneyBadgerApp/Config/APIConfig.swift`
   - Update `baseURL` if needed (default: `http://localhost:3000`)

3. **Build and run:**
   - Select a simulator or device
   - Press `Cmd + R` to build and run
   - Or click the Play button in Xcode

### Backend Connection

**IMPORTANT**: The iOS app requires the Node.js backend to be running.

1. **Start the backend:**
   ```bash
   cd ../honey-badger-backend
   npm run dev
   ```

2. **Backend should run on:** `http://localhost:3000`

3. **For iOS Simulator:** Use `http://localhost:3000`
4. **For Physical Device:** Use your Mac's IP address (e.g., `http://192.168.1.100:3000`)

## Project Structure

```
honey-badger-ios/
├── HoneyBadgerApp.xcodeproj/     # Xcode project file
├── HoneyBadgerApp/               # Main app source
│   ├── Config/                   # Configuration files
│   │   ├── APIConfig.swift       # Backend API configuration
│   │   └── NetworkManager.swift  # API client
│   ├── Assets.xcassets/          # Image assets
│   │   ├── AppIcon.appiconset/   # App icon
│   │   ├── CyberBadger.imageset/
│   │   ├── HB_Gift.imageset/
│   │   └── ...                   # Other image assets
│   ├── HoneyBadgerApp.xcdatamodeld/  # Core Data model
│   ├── HoneyBadgerAppApp.swift   # App entry point
│   ├── ContentView.swift         # Root view
│   ├── HoneyBadgerComplete.swift # Main UI (1,844 lines)
│   └── Persistence.swift         # Core Data setup
├── HoneyBadgerAppTests/          # Unit tests
├── HoneyBadgerAppUITests/        # UI tests
├── QUICK_START.md                # Quick start guide
├── SUPABASE_IOS_SETUP.md         # (Legacy) Supabase docs
├── FIX_BUILD_NOW.md              # Build troubleshooting
├── API_INTEGRATION.md            # Backend integration guide
├── .gitignore
└── README.md                     # This file
```

## Features

### Authentication
- Email and password signup
- Login with JWT tokens
- Secure token storage in UserDefaults
- Auto-login on app launch
- Logout functionality

### Gift Management
- Send Honey Badger gifts with challenges
- View sent gifts
- Track challenge progress
- Multiple gift types: gift cards, cash, photos, messages

### Challenge Types
- Photo Challenge
- Video Challenge
- Text Challenge
- Keyword Challenge
- Multi-Day Challenge
- Custom Challenge

### Contact Management
- Add/edit/delete contacts
- Import from iOS Contacts app
- Store contact details
- Track special dates
- Quick-send to contacts

### UI/UX
- Dark theme with honey badger branding
- Bright yellow (#E2FF00) accents
- Smooth animations and transitions
- Responsive layouts for all screen sizes
- Native iOS controls and gestures

## Configuration

### API Backend URL

Edit `HoneyBadgerApp/Config/APIConfig.swift`:

```swift
struct APIConfig {
    // Development
    static let baseURL = "http://localhost:3000"

    // Production (uncomment for release)
    // static let baseURL = "https://api.honeybadger.com"
}
```

**For iOS Simulator:**
- Use `http://localhost:3000` (works as-is)

**For Physical Device:**
- Find your Mac's local IP:
  ```bash
  ipconfig getifaddr en0  # macOS
  ```
- Update `baseURL` to `http://YOUR_IP:3000`
- Ensure firewall allows connections

### Build Configurations

The project includes two build configurations:

1. **Debug**: Uses localhost backend
2. **Release**: Uses production backend (update APIConfig)

## API Integration

The app communicates with the Node.js backend via the `NetworkManager` class.

### Authentication Flow

```swift
let networkManager = NetworkManager()

// Login
let response = try await networkManager.login(email: "user@example.com", password: "password")
// Token is automatically stored

// Get current user
let user = try await networkManager.getCurrentUser()

// Logout
try await networkManager.logout()
// Token is automatically cleared
```

### Available Methods

**Authentication:**
- `login(email:password:) -> AuthResponse`
- `signup(name:email:password:phone:) -> AuthResponse`
- `getCurrentUser() -> User`
- `logout()`

**Gifts:**
- `sendGift(recipientPhone:giftType:challengeType:giftDetails:) -> GiftResponse`
- `getGifts() -> [Gift]`

**Contacts:**
- `getContacts() -> [Contact]`
- `addContact(name:phone:email:notes:) -> Contact`

See `HoneyBadgerApp/Config/NetworkManager.swift` for complete API.

## Migration from Supabase

**NOTE**: This repo has been migrated from Supabase to Node.js backend.

### What's Changed

- ✅ `APIConfig.swift` added - Backend configuration
- ✅ `NetworkManager.swift` added - API client
- ⚠️ Supabase dependencies still present (need removal)
- ⚠️ `HoneyBadgerComplete.swift` needs update to use NetworkManager

### Complete Migration Steps

See `API_INTEGRATION.md` for detailed instructions on:
1. Removing Supabase Swift Package
2. Deleting Supabase config files
3. Updating HoneyBadgerComplete.swift
4. Testing authentication flow

## Building

### Development Build

```bash
# Open in Xcode
open HoneyBadgerApp.xcodeproj

# Build (Cmd + B)
# Run (Cmd + R)
```

### Production Build

1. **Update API URL** in `APIConfig.swift` to production
2. **Update App Version** in project settings
3. **Update Bundle Identifier** if needed
4. **Archive** the app (Product → Archive)
5. **Validate** the archive
6. **Distribute** to TestFlight or App Store

### Code Signing

- Requires Apple Developer account
- Configure signing in Xcode project settings
- Use automatic or manual signing

## Testing

### Unit Tests

```bash
# Run tests in Xcode
Cmd + U
```

### UI Tests

```bash
# Run UI tests in Xcode
Cmd + U (with UI tests target selected)
```

### Manual Testing Checklist

- [ ] Signup with new account
- [ ] Login with existing account
- [ ] Send a Honey Badger gift
- [ ] View sent gifts
- [ ] Add contact from Contacts app
- [ ] Logout and verify token cleared

## Troubleshooting

### Build Errors

**Issue**: "No such module 'Supabase'"
- **Solution**: Remove Supabase package from project dependencies (see API_INTEGRATION.md)

**Issue**: "Cannot connect to backend"
- **Solution**: Verify backend is running on `http://localhost:3000`
- Check firewall settings
- Update `baseURL` in `APIConfig.swift` to your Mac's IP

### Authentication Issues

**Issue**: "Unauthorized" error
- **Solution**: Token expired or invalid. Clear app data and login again.
- In simulator: Reset Content and Settings

**Issue**: "Invalid credentials"
- **Solution**: Verify email/password. Check backend logs for errors.

### Network Errors

**Issue**: "The network connection was lost"
- **Solution**: Ensure backend is running and reachable
- Check iOS network permissions
- Test backend with curl: `curl http://localhost:3000/health`

## Deployment

### TestFlight (Beta Testing)

1. Archive the app in Xcode
2. Upload to App Store Connect
3. Add testers via email
4. Testers receive invite to download via TestFlight

### App Store

1. Complete App Store Connect setup
2. Prepare app metadata (screenshots, description, etc.)
3. Submit for review
4. Wait for Apple approval (1-3 days typically)

## Performance

- **Launch Time**: < 2s cold start
- **Memory Usage**: ~50-80 MB typical
- **Network**: Minimal data usage, efficient API calls
- **Battery**: Optimized for low power consumption

## Security

- **Token Storage**: UserDefaults (consider Keychain for production)
- **HTTPS**: Required in production
- **API Authentication**: JWT bearer tokens
- **Input Validation**: Client-side + server-side
- **No hardcoded secrets**: All config in APIConfig.swift

## Contributing

This is a proprietary project. Contact the development team for contribution guidelines.

## License

Proprietary - Honey Badger AI Gifts

## Support

For issues or questions:
- Check `QUICK_START.md` for quick fixes
- See `API_INTEGRATION.md` for backend integration help
- Contact development team for additional support
