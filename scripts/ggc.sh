#!/usr/bin/env bash
if [ ! -f "./pubspec.yaml" ]; then
  cd ../
fi
#flutter pub run build_runner build --delete-conflicting-outputs && flutter pub get
flutter pub run build_runner clean && flutter pub run build_runner build --delete-conflicting-outputs && flutter pub get