# Reef chain mobile app

Use Reef chain on mobile phone

## Getting Started
This mobile app uses Flutter framework. Run it with "flutter run". For any issues check "flutter doctor".

Js libraries are used for interaction with the chain inside "lib/js/packages/reef-mobile-js" directory. Install dependencies running "yarn" in "lib/js" directory. Run them with "yarn start".

For linking with Firebase, run this 

```
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutterfire configure
```

To run it with env variables, use the following

```
flutter run --dart-define-from-file=<FILE_NAME>.json
```

NOTE: The filetype should be json & must have the following syntax

```
{
    "FIREBASE_API_KEY": "",
    "FIREBASE_APP_ID_ANDROID":"",
    "FIREBASE_APP_ID_IOS":"",
    "FIREBASE_MESSAGING_SENDER_ID": 0,
    "FIREBASE_PROJECT_ID":"",
    "FIREBASE_STORAGE_BUCKET":"",
    "FIREBASE_IOS_BUNDLE_ID":""
}
```

Mobx is used for Flutter state management. If updating its classes run "flutter pub run build_runner watch"

🌍 Internationalization : This app uses the Internationalization library to provide support for multiple languages. To use this library, you will need to run the following command "flutter gen-l10n"

This will generate the necessary localization files for your app. You can then add your own translations to these files to make your app accessible to users in different countries and regions. The location is "/lib/l10n" , it contains key value pairs. 

Nomenclature : app_<language_code>.arb 

Thank you for using 🌊 Reef Chain Mobile App!
