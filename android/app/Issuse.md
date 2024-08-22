/Users/apple/Work/github/flutter_tomoto/android/app/src/debug/AndroidManifest.xml Error:
uses-sdk:minSdkVersion 19 cannot be smaller than version 21 declared in library [:background_downloader] /Users/apple/Work/github/flutter_tomoto/build/background_downloader/intermediates/merged_manifest/debug/AndroidManifest.xml as the library might be using APIs not available in 19
Suggestion: use a compatible library with a minSdk of at most 19,
or increase this project's minSdk version to at least 21,
or use tools:overrideLibrary="com.bbflight.background_downloader" to force usage (may lead to runtime failures)

FAILURE: Build failed with an exception.

* What went wrong:
  Execution failed for task ':app:processDebugMainManifest'.
> Manifest merger failed : uses-sdk:minSdkVersion 19 cannot be smaller than version 21 declared in library [:background_downloader] /Users/apple/Work/github/flutter_tomoto/build/background_downloader/intermediates/merged_manifest/debug/AndroidManifest.xml as the library might be using APIs not available in 19
Suggestion: use a compatible library with a minSdk of at most 19,
or increase this project's minSdk version to at least 21,
or use tools:overrideLibrary="com.bbflight.background_downloader" to force usage (may lead to runtime failures)

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.