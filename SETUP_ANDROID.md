# Android SDK Setup Guide for Reef Mobile Wallet

## 📱 Quick Setup After Android Studio Installation

### Step 1: Verify Android SDK Installation

Check if Android SDK is installed:

```bash
ls "C:\Users\DanielV\AppData\Local\Android\Sdk"
```

You should see folders like:
- `emulator/`
- `platform-tools/`
- `platforms/`
- `build-tools/`
- `system-images/`

---

### Step 2: Configure Flutter with Android SDK

Once Android Studio finishes installing the SDK, run:

```bash
# Configure Flutter to use Android SDK
flutter config --android-sdk C:\Users\DanielV\AppData\Local\Android\Sdk

# Verify the configuration
flutter doctor -v
```

**Expected Output:**
```
[✓] Android toolchain - develop for Android devices (Android SDK version 36.x.x)
    • Android SDK at C:\Users\DanielV\AppData\Local\Android\Sdk
    • Platform android-36, build-tools 36.x.x
    • Java binary at: ...
    • Java version ...
```

---

### Step 3: Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Type `y` to accept all licenses.

---

### Step 4: Install Dependencies for Reef Mobile App

Navigate to the mobile-app directory and install packages:

```bash
cd "D:\Reef Chain Project\mobile-app"

# Install Flutter dependencies
flutter pub get

# Install JavaScript dependencies for reef-mobile-js
cd lib/js
npm install
# or
yarn install

cd ../..
```

---

### Step 5: Run the App

#### Option A: Run on Android Emulator

1. **Start the emulator:**
   ```bash
   # List available emulators
   flutter emulators

   # Launch an emulator (will be created by Android Studio)
   flutter emulators --launch <emulator_name>
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

#### Option B: Run on Physical Android Device

1. **Enable Developer Options on your phone:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect phone via USB**

3. **Verify device is detected:**
   ```bash
   flutter devices
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

### Step 6: Build JavaScript Bridge (if needed)

The app uses JavaScript libraries to communicate with the blockchain.

```bash
cd "D:\Reef Chain Project\mobile-app\lib\js"

# Install dependencies
yarn install

# Build the JavaScript bridge
yarn start
# or
npm run start
```

This creates: `lib/js/packages/reef-mobile-js/dist/index.js`

---

## 🔧 Troubleshooting

### Issue: "Unable to locate Android SDK"

**Solution:**
```bash
flutter config --android-sdk C:\Users\DanielV\AppData\Local\Android\Sdk
```

---

### Issue: "Gradle build failed"

**Solution:**
1. Check Android SDK is fully installed
2. Accept licenses: `flutter doctor --android-licenses`
3. Clean build: `flutter clean && flutter pub get`

---

### Issue: "No connected devices"

**For Emulator:**
```bash
# List emulators
flutter emulators

# Create new emulator in Android Studio if none exists
# Then launch it
flutter emulators --launch <name>
```

**For Physical Device:**
- Ensure USB Debugging is enabled
- Use original USB cable
- Install device drivers if on Windows

---

### Issue: "JavaScript build not found"

**Solution:**
```bash
cd lib/js
yarn install
yarn start
```

---

## 📊 Verify Setup is Complete

Run this command to check everything:

```bash
flutter doctor -v
```

**You should see ✓ for:**
- ✓ Flutter (Channel stable, 3.38.5)
- ✓ Android toolchain
- ✓ Chrome (for web development)
- ✓ Connected device (emulator or physical)

---

## 🚀 Quick Start Commands

After setup is complete:

```bash
# Navigate to project
cd "D:\Reef Chain Project\mobile-app"

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in release mode (faster)
flutter run --release

# Build APK for distribution
flutter build apk --release
```

---

## 📝 Development Tips

### Hot Reload
While app is running, press:
- `r` - Hot reload (fast)
- `R` - Hot restart (slower, full restart)
- `q` - Quit

### Debugging
```bash
# Run with verbose logging
flutter run -v

# Open DevTools for debugging
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Profiling
```bash
# Run in profile mode
flutter run --profile

# Open DevTools → Performance tab
```

---

## 🎯 Testing the Improvements

After the app is running, test the improvements:

### Test #1: Memory Leak Fix
1. Open app
2. Navigate to DApp browser
3. Connect to a DApp
4. Open DevTools → Memory tab
5. Disconnect and reconnect 10 times
6. **Expected:** Memory stays stable

### Test #2: Phishing Protection
1. Try connecting to test domains
2. Check console for phishing warnings
3. **Expected:** Suspicious domains are flagged

### Test #3: Error Handling
1. Try signing with wrong password
2. Try signing with network off
3. **Expected:** Specific error messages

---

## 📚 Additional Resources

- **Flutter Documentation:** https://docs.flutter.dev
- **Android Developer Guide:** https://developer.android.com
- **Reef Chain Docs:** https://docs.reef.io
- **Reef Mobile App Repo:** https://github.com/reef-chain/mobile-app

---

## ✅ Checklist

- [ ] Android SDK installed
- [ ] Flutter configured with Android SDK
- [ ] Android licenses accepted
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] JavaScript dependencies installed (`yarn install` in lib/js)
- [ ] JavaScript build created (`yarn start` in lib/js)
- [ ] Emulator created or physical device connected
- [ ] App runs successfully (`flutter run`)
- [ ] All improvements tested

---

**Last Updated:** 2025-12-22
**Status:** Ready for Testing Once SDK Installation Completes
