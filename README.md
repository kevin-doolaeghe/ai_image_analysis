# AI Image Analysis - Flutter

## Author

Kevin DOOLAEGHE

## References

* [Firebase console](https://console.firebase.google.com/u/0/?pli=1)
* [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
* [Google Docs - Add Firebase to your Flutter application](https://firebase.google.com/docs/flutter/setup?platform=ios)
* [Google Docs - Get Started with Realtime Database](https://firebase.google.com/docs/database/flutter/start)
* [Google Codelab - Get to know Firebase for Flutter](https://firebase.google.com/codelabs/firebase-get-to-know-flutter#0)

## Setup a new Flutter project

* Create a new project called `ai_image_analysis` :

```
flutter create ai_image_analysis
```

* Open the created directory with your favorite IDE (e.g. Visual Studio Code) :

```
cd .\ai_image_analysis\
code .
```

## Setup the Git repository

* Initialize a new Git repository :

```
git init
```

* Add and commit all new files :

```
git add .
git commit -m "Initialized project"
```

* Link your local repository to a freshly created remote repository on Git, then push the project :

```
git remote add origin https://github.com/kevin-doolaeghe/ai_image_analysis.git
git push --set-upstream origin master
```

## Setup the Firebase CLI on your local machine

To use `npm` (the Node Package Manager) to install the Firebase CLI, follow these steps:

1. Install [Node.js](https://www.nodejs.org/) using [nvm-windows](https://github.com/coreybutler/nvm-windows) (the Node Version Manager). Installing Node.js automatically installs the `npm` command tools.

2. Install the Firebase CLI via npm by running the following command:

```
npm install -g firebase-tools
```

3. Log into Firebase using your Google account :

```
firebase login
```

## Setup the FlutterFire CLI on your local machine

1. Install the FlutterFire CLI by running the following command from any directory :

```
dart pub global activate flutterfire_cli
```

2. If the following warning appears, you must add the `pub` executables folder to the `Path` environment variable :

> Warning: Pub installs executables into C:\Users\Kevin\AppData\Local\Pub\Cache\bin, which is not on your path.
> You can fix that by adding that directory to your system's "Path" environment variable.

## Configure your Firebase project 

* Create a new project on [Firebase console](https://console.firebase.google.com/u/0/?pli=1).

* Link your Firebase project to the Flutter project :

```
flutterfire configure --project=ai-image-analysis
```

## Initialize Firebase in your application

* Add the `firebase_core` plugin to the project :

```
flutter pub add firebase_core
```

* From your Flutter project directory, run the following command to ensure that your Flutter app's Firebase configuration is up-to-date :

```
flutterfire configure
```

* In your `lib/main.dart` file, import the Firebase core plugin and the configuration file you generated earlier:

```
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

* Also in your `lib/main.dart` file, initialize Firebase using the DefaultFirebaseOptions object exported by the configuration file:

```
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Rebuild the project

* Run the following command, then select your testing environment :

```
flutter run
```

## Push your project to Git

* Commit and push your changes to Git :

```
git add .
git commit -m "Linked Firebase project"
git push
```
