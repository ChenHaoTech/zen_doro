#!/usr/bin/env bash
# [flutter_launcher_icons |Dart包 --- flutter_launcher_icons | Dart package](https://pub.dev/packages/flutter_launcher_icons)
if [ ! -f "./pubspec.yaml" ]; then
  cd ../
fi
flutter pub get
flutter pub run flutter_launcher_icons
git add .
git commit -m "chang icon"