#!/usr/bin/env bash
cd ../
function rm_lock_file(){
  rm -f ./path/file./macos/Podfile.lock
  rm -f ./pubspec.lock
  rm -f ./ios/Podfile.lock

  echo "clear lock file"
}

function fl_clear_pub_get() {
    flutter clean && flutter pub get
}

#  去 ios 目录下 pod install
function pod_install() {
    cd $1 && pod install && cd ../
}

rm_lock_file && fl_clear_pub_get &&  pod_install macos