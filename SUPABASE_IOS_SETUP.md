# iOS App - Supabase Integration Setup

## Step 1: Add Supabase Swift SDK via Swift Package Manager

1. **Open your project in Xcode**
2. Go to **File** → **Add Package Dependencies...**
3. In the search bar, paste:
   ```
   https://github.com/supabase/supabase-swift
   ```
4. Click **Add Package**
5. **Select these products** when prompted:
   - ✅ `Supabase`
   - ✅ `Auth`
   - ✅ `PostgREST`
   - ✅ `Realtime` (optional, for live updates)
6. Click **Add Package**

Wait for Xcode to fetch and integrate the package (may take 1-2 minutes).

## Step 2: Create Supabase Configuration File

This file will be created for you: `HoneyBadgerApp/Config/SupabaseConfig.swift`

**Important:** You need to add your Supabase credentials after creating your project.

## Step 3: Add Config Folder to Xcode

1. In Xcode Project Navigator, right-click on **HoneyBadgerApp** folder (blue icon)
2. Choose **New Group**
3. Name it `Config`
4. Right-click on the new `Config` folder
5. Choose **Add Files to "HoneyBadgerApp"...**
6. Navigate to: `HoneyBadgerApp/Config/SupabaseConfig.swift`
7. Make sure **"Copy items if needed"** is unchecked (file is already in the right place)
8. Click **Add**

## Step 4: Add Your Supabase Credentials

1. Open `SupabaseConfig.swift` in Xcode
2. Replace the placeholder values:
   ```swift
   static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
   static let supabaseAnonKey = "YOUR_ANON_KEY"
   ```
3. Get these from: Supabase Dashboard → Project Settings → API

## Step 5: Update App to Use Supabase Auth

The following files have been updated for you:
- `HoneyBadgerComplete.swift` - Will use real Supabase authentication
- `Models/User.swift` - Updated to match Supabase user structure
- `Services/SupabaseAuthManager.swift` - New authentication service

## Step 6: Build and Test

1. **Clean Build Folder**: `Cmd + Shift + K`
2. **Build**: `Cmd + B`
3. **Run**: `Cmd + R`

## Testing Authentication

### Test Signup Flow:
1. Launch app in simulator
2. Click **Sign Up** / **Login**
3. Enter email: `test@example.com`
4. Enter password: `Test123!` (must be 6+ characters)
5. Click **Sign Up**

You should see:
- User created in Supabase (check Dashboard → Authentication → Users)
- App navigates to Dashboard
- User stays logged in (Supabase handles session persistence)

### Test Login Flow:
1. Close and reopen the app
2. Should automatically log in (session persisted)
3. Or click Login and use same credentials

### Test Logout:
1. Click logout button in dashboard
2. Should return to landing page
3. Session cleared

## Architecture Overview

```
┌─────────────────────────────────┐
│     HoneyBadgerComplete.swift   │
│  (Main Views: Landing, Login,   │
│   Dashboard)                    │
└────────────┬────────────────────┘
             │
             │ Uses @EnvironmentObject
             ▼
┌─────────────────────────────────┐
│   SupabaseAuthManager.swift     │
│  (ObservableObject)             │
│  - signup()                     │
│  - login()                      │
│  - logout()                     │
│  - getCurrentUser()             │
└────────────┬────────────────────┘
             │
             │ Calls
             ▼
┌─────────────────────────────────┐
│    SupabaseConfig.swift         │
│  (Shared Supabase client)       │
│  - supabase.auth.signUp()       │
│  - supabase.auth.signIn()       │
│  - supabase.auth.signOut()      │
└─────────────────────────────────┘
             │
             │ Network calls
             ▼
┌─────────────────────────────────┐
│       Supabase Cloud            │
│  (Authentication + Database)    │
└─────────────────────────────────┘
```

## Environment Variables Alternative (More Secure)

Instead of hardcoding credentials in `SupabaseConfig.swift`, you can use an `.xcconfig` file:

1. Create `Config.xcconfig`:
   ```
   SUPABASE_URL = https:/$()/YOUR_PROJECT_ID.supabase.co
   SUPABASE_ANON_KEY = YOUR_ANON_KEY
   ```

2. Add to Xcode:
   - Project Settings → Configurations → Debug/Release
   - Set Config.xcconfig for each

3. Update `SupabaseConfig.swift` to read from `Info.plist`

**For now, hardcoded values are fine for development.**

## Troubleshooting

### "No such module 'Supabase'"
- Make sure you added the Supabase package
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode

### "Type 'SupabaseAuthManager' does not conform to 'ObservableObject'"
- Make sure `import Combine` is at the top of the file
- Rebuild: `Cmd + B`

### Authentication errors
- Check Supabase URL and anon key are correct
- Check Supabase Dashboard → Authentication → Providers → Email is enabled
- Check network connection (Simulator → Settings → Wi-Fi)

### "User already registered"
- Check Supabase Dashboard → Authentication → Users
- Delete test users or use different email

## Next Steps

After getting iOS auth working:
1. Update Node.js backend to verify Supabase tokens
2. Connect iOS app to Node.js API for gift operations
3. Test full flow: Auth → Create Gift → SMS notification

## Security Notes

- ✅ `supabaseAnonKey` is safe to include in iOS app (it's public)
- ✅ Supabase handles all password hashing and security
- ✅ JWT tokens are stored securely in iOS Keychain by Supabase SDK
- ❌ Never include `service_role` key in iOS app
- ✅ Use Row Level Security (RLS) policies in Supabase for data access control
