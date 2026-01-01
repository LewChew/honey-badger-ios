# API Integration Guide: Migrating from Supabase to Node.js Backend

This guide provides step-by-step instructions for completing the migration from Supabase to the Node.js backend.

## Migration Status

✅ **Completed:**
- Created `Config/APIConfig.swift` - Backend configuration
- Created `Config/NetworkManager.swift` - Full API client implementation
- Documented all API endpoints
- Implemented authentication flow

⚠️ **Remaining Tasks:**
1. Remove Supabase Swift Package from Xcode project
2. Delete Supabase configuration files
3. Update `HoneyBadgerComplete.swift` to use NetworkManager
4. Test all authentication flows

---

## Step 1: Remove Supabase Swift Package

### Option A: Via Xcode (Recommended)

1. **Open the project:**
   ```bash
   open HoneyBadgerApp.xcodeproj
   ```

2. **Open Package Dependencies:**
   - Click on project file in Navigator
   - Select the project (not target)
   - Go to "Package Dependencies" tab

3. **Remove Supabase package:**
   - Find `supabase-swift` in the list
   - Click the `-` (minus) button to remove it
   - Confirm removal

4. **Clean build folder:**
   - Menu: Product → Clean Build Folder (Shift + Cmd + K)

### Option B: Manual Cleanup

If Xcode removal doesn't work:

```bash
# Delete Package.resolved
rm -rf HoneyBadgerApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reopen project
open HoneyBadgerApp.xcodeproj
```

---

## Step 2: Delete Supabase Configuration Files

### Files to Delete:

```bash
# From terminal
cd HoneyBadgerApp/HoneyBadgerApp/Config

# Delete Supabase files
rm -f SupabaseConfig.swift
rm -f SupabaseAuthManager.swift
```

### Or via Xcode:

1. Navigate to `HoneyBadgerApp/Config/` in Project Navigator
2. Right-click on `SupabaseConfig.swift` → Delete → Move to Trash
3. Right-click on `SupabaseAuthManager.swift` → Delete → Move to Trash

---

## Step 3: Update HoneyBadgerComplete.swift

This is the main change required. The file currently uses `SupabaseAuthManager`, which needs to be replaced with `NetworkManager`.

### 3.1 Find Current Authentication Code

Open `HoneyBadgerApp/HoneyBadgerComplete.swift` and locate the authentication manager:

**Current code (Supabase):**
```swift
@StateObject private var authManager = SupabaseAuthManager()
```

**Replace with (Node.js):**
```swift
@StateObject private var networkManager = NetworkManager()
```

### 3.2 Update Login Function

**Current code (Supabase):**
```swift
func login() {
    Task {
        do {
            try await authManager.login(email: email, password: password)
            // Success handling
        } catch {
            // Error handling
        }
    }
}
```

**Replace with (Node.js):**
```swift
func login() {
    Task {
        do {
            let response = try await networkManager.login(email: email, password: password)
            // Token is automatically stored in networkManager
            currentUser = response.user
            isAuthenticated = true
            // Success handling
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            // Error handling
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
}
```

### 3.3 Update Signup Function

**Current code (Supabase):**
```swift
func signup() {
    Task {
        do {
            try await authManager.signup(email: email, password: password, name: name, phone: phone)
            // Success handling
        } catch {
            // Error handling
        }
    }
}
```

**Replace with (Node.js):**
```swift
func signup() {
    Task {
        do {
            let response = try await networkManager.signup(
                name: name,
                email: email,
                password: password,
                phone: phone
            )
            currentUser = response.user
            isAuthenticated = true
            // Success handling
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            // Error handling
        } catch {
            errorMessage = "Signup failed: \(error.localizedDescription)"
        }
    }
}
```

### 3.4 Update Logout Function

**Current code (Supabase):**
```swift
func logout() {
    Task {
        try? await authManager.logout()
        isAuthenticated = false
    }
}
```

**Replace with (Node.js):**
```swift
func logout() {
    Task {
        do {
            try await networkManager.logout()
            currentUser = nil
            isAuthenticated = false
        } catch {
            // Even if logout fails on server, clear local state
            networkManager.authToken = nil
            currentUser = nil
            isAuthenticated = false
        }
    }
}
```

### 3.5 Update Auto-Login Check

**Current code (Supabase):**
```swift
func checkAuthStatus() {
    Task {
        if authManager.currentUser != nil {
            isAuthenticated = true
        }
    }
}
```

**Replace with (Node.js):**
```swift
func checkAuthStatus() {
    Task {
        if networkManager.authToken != nil {
            do {
                currentUser = try await networkManager.getCurrentUser()
                isAuthenticated = true
            } catch {
                // Token invalid, clear it
                networkManager.authToken = nil
                isAuthenticated = false
            }
        }
    }
}
```

### 3.6 Complete Example Replacement

**Before (Supabase):**
```swift
import SwiftUI
import Supabase

struct HoneyBadgerMainView: View {
    @StateObject private var authManager = SupabaseAuthManager()
    @State private var isAuthenticated = false
    @State private var email = ""
    @State private var password = ""

    var body some View {
        if isAuthenticated {
            DashboardView()
        } else {
            LoginView()
        }
    }
}
```

**After (Node.js):**
```swift
import SwiftUI
import Combine

struct HoneyBadgerMainView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var isAuthenticated = false
    @State private var currentUser: User? = nil
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        if isAuthenticated {
            DashboardView(networkManager: networkManager, user: currentUser)
        } else {
            LoginView(networkManager: networkManager, isAuthenticated: $isAuthenticated)
        }
    }

    func login() {
        Task {
            do {
                let response = try await networkManager.login(email: email, password: password)
                currentUser = response.user
                isAuthenticated = true
            } catch let error as NetworkError {
                errorMessage = error.localizedDescription
            }
        }
    }
}
```

---

## Step 4: Update Import Statements

### Remove Supabase Imports

**Find and remove:**
```swift
import Supabase
import Postgrest
import Realtime
import Storage
import Auth
```

**Keep/Add:**
```swift
import Foundation
import Combine
import SwiftUI
```

---

## Step 5: Test Authentication Flow

### 5.1 Start Backend

```bash
cd ../honey-badger-backend
npm run dev
```

Verify backend is running:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{"status":"healthy","timestamp":"2026-01-01T..."}
```

### 5.2 Test Signup

1. Run the iOS app in simulator
2. Go to Signup screen
3. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: Test123
   - Phone: +1234567890 (optional)
4. Tap "Sign Up"
5. Should see success and redirect to dashboard

### 5.3 Test Login

1. Logout from the app
2. Go to Login screen
3. Enter credentials from signup
4. Tap "Login"
5. Should see success and redirect to dashboard

### 5.4 Verify Token Persistence

1. Close the app completely
2. Reopen the app
3. Should auto-login (if token valid)
4. Should see dashboard without login screen

### 5.5 Test Logout

1. Tap logout button
2. Should clear session
3. Should return to login screen
4. Reopen app - should stay on login screen

---

## Step 6: Debugging

### Enable Network Logging

Add to `NetworkManager.swift` init:

```swift
init() {
    self.authToken = UserDefaults.standard.string(forKey: "authToken")

    // Debug: Print token status
    #if DEBUG
    print("🔐 NetworkManager initialized")
    print("🔑 Token present: \(authToken != nil)")
    print("🌐 Base URL: \(APIConfig.baseURL)")
    #endif
}
```

### Common Issues

**Issue**: "Invalid Response"
- **Check**: Is backend running?
- **Fix**: `cd ../honey-badger-backend && npm run dev`

**Issue**: "Unauthorized"
- **Check**: Is token expired?
- **Fix**: Clear UserDefaults and login again
  ```swift
  UserDefaults.standard.removeObject(forKey: "authToken")
  ```

**Issue**: "Cannot connect to backend"
- **Check**: Using correct URL?
- **For Simulator**: Use `http://localhost:3000`
- **For Device**: Use `http://YOUR_IP:3000`

**Issue**: "Decoding error"
- **Check**: Backend response format matches Swift models
- **Debug**: Print raw response:
  ```swift
  let responseString = String(data: data, encoding: .utf8)
  print("Response: \(responseString ?? "nil")")
  ```

---

## Step 7: Production Considerations

### Security Improvements

1. **Move token to Keychain:**
   ```swift
   // Instead of UserDefaults, use Keychain
   import Security

   func saveToken(_ token: String) {
       let data = token.data(using: .utf8)!
       let query: [String: Any] = [
           kSecClass as String: kSecClassGenericPassword,
           kSecAttrAccount as String: "authToken",
           kSecValueData as String: data
       ]
       SecItemAdd(query as CFDictionary, nil)
   }
   ```

2. **Use HTTPS in production:**
   ```swift
   #if DEBUG
   static let baseURL = "http://localhost:3000"
   #else
   static let baseURL = "https://api.honeybadger.com"
   #endif
   ```

3. **Certificate pinning:**
   - Add SSL certificate pinning for production
   - Prevent man-in-the-middle attacks

---

## Step 8: Clean Up Legacy Files

### Remove Supabase Documentation

```bash
# Optional: Remove old Supabase setup docs
rm -f SUPABASE_IOS_SETUP.md
```

### Update Build Scripts

If you have any build scripts that reference Supabase, update them.

---

## Verification Checklist

- [ ] Supabase Swift Package removed from Xcode
- [ ] `SupabaseConfig.swift` deleted
- [ ] `SupabaseAuthManager.swift` deleted
- [ ] `HoneyBadgerComplete.swift` updated to use `NetworkManager`
- [ ] All Supabase imports removed
- [ ] Backend running on port 3000
- [ ] Signup flow works
- [ ] Login flow works
- [ ] Auto-login works (token persistence)
- [ ] Logout works
- [ ] No build errors
- [ ] App runs on simulator
- [ ] App runs on physical device (if testing)

---

## Next Steps

After completing authentication migration:

1. **Add gift sending functionality:**
   - Use `networkManager.sendGift(...)`
   - Update gift list view

2. **Add contact management:**
   - Use `networkManager.getContacts()`
   - Use `networkManager.addContact(...)`

3. **Add error handling UI:**
   - Show user-friendly error messages
   - Handle network failures gracefully

4. **Add loading states:**
   - Show spinners during API calls
   - Disable buttons during requests

---

## Support

If you encounter issues during migration:

1. Check this guide first
2. Review `NetworkManager.swift` implementation
3. Check backend logs for errors
4. Test backend endpoints with curl
5. Contact development team if stuck
