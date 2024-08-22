if [ ! -f "./pubspec.yaml" ]; then
  cd ../
fi

flutter build ipa --release && open ./build/ios/iphoneos
echo "build ipa 成功"