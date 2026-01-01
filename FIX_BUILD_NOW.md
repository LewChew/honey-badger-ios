# Fix Build Error - Quick Solutions

## Error
```
No such module 'Supabase'
```

This happens because the Supabase Swift SDK hasn't been added to your Xcode project yet.

## ✅ Solution 1: Add Supabase Package (5 minutes - RECOMMENDED)

This is the proper fix that enables real authentication:

### Steps:

1. **In Xcode**, go to **File** → **Add Package Dependencies...**

2. **Paste this URL** in the search box:
   ```
   https://github.com/supabase/supabase-swift
   ```

3. **Click "Add Package"**

4. **Select these libraries** when prompted:
   - ✅ Supabase
   - ✅ Auth
   - ✅ PostgREST
   - ⬜ Realtime (optional)
   - ⬜ Storage (optional)

5. **Click "Add Package"** again

6. **Wait** for Xcode to download (30-60 seconds)

7. **Clean Build**: Press `Cmd + Shift + K`

8. **Build**: Press `Cmd + B`

9. **Done!** Error should be gone ✅

### If It Still Errors:

- Make sure the package is added to your **HoneyBadgerApp target**
- Restart Xcode
- Try cleaning again: `Cmd + Shift + K`

---

## ⚡ Solution 2: Remove Supabase Files Temporarily (30 seconds)

If you just want to build the app NOW and add Supabase later:

### Steps:

1. **In Xcode Project Navigator** (left sidebar)

2. **Find the Config folder** with these files:
   - SupabaseConfig.swift
   - SupabaseAuthManager.swift

3. **Select BOTH files**

4. **Right-click** → **Delete**

5. **Choose**: "Remove Reference" (NOT "Move to Trash")
   - This removes them from Xcode but keeps the files on disk

6. **Clean Build**: `Cmd + Shift + K`

7. **Build**: `Cmd + B`

8. **App should build!** ✅

The app will use the mock authentication in `HoneyBadgerComplete.swift`.

### To Add Them Back Later:

1. Follow Solution 1 to add Supabase package
2. Right-click on Config folder → "Add Files to HoneyBadgerApp..."
3. Select both files
4. Click Add

---

## 🎯 Which Solution Should I Use?

| Situation | Solution |
|-----------|----------|
| Want real Supabase auth NOW | **Solution 1** (5 min) |
| Just testing UI styling | **Solution 2** (30 sec) |
| Not ready to set up Supabase | **Solution 2** (30 sec) |
| Ready to go to production | **Solution 1** (required) |

---

## After Fixing the Build Error

Once the app builds successfully, you'll see:

1. **Landing Page** with yellow glowing logo
2. **Login/Signup** buttons
3. **Dark theme** with gradient buttons
4. **Dashboard** after login

### If Using Solution 1 (Supabase):
- You'll need to update `Config/SupabaseConfig.swift` with your credentials
- See `SUPABASE_IOS_SETUP.md` for details

### If Using Solution 2 (Mock Auth):
- Any email/password will work
- Login happens instantly (simulated)
- Good for testing UI flows

---

## Troubleshooting

### "Package Resolution Failed"
- Check internet connection
- Try again in a few minutes
- URL is correct: `https://github.com/supabase/supabase-swift`

### "Cannot find 'SupabaseClient' in scope"
- Make sure you selected "Supabase" product when adding package
- Clean build folder: `Cmd + Shift + K`
- Restart Xcode

### "Build Failed" after removing files
- Make sure you chose "Remove Reference" not "Move to Trash"
- Check that `HoneyBadgerComplete.swift` is still in the project
- Clean build: `Cmd + Shift + K`

---

## Quick Commands

```bash
# Clean build
Cmd + Shift + K

# Build project
Cmd + B

# Run app
Cmd + R

# Stop app
Cmd + .
```

---

**Recommendation**: Use **Solution 1** if you have 5 minutes. It's the proper setup and you'll need it anyway for production. Use **Solution 2** only if you're in a rush to see the UI working.
