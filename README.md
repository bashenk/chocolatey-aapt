# chocolatey-aapt

AAPT (Android Asset Packaging Tool) is a build tool that Android Studio and Android Gradle Plugin use to compile and package your app’s resources. AAPT parses, indexes, and compiles the resources into a binary format that is optimized for the Android platform.

See <https://developer.android.com/studio/command-line/aapt2> or <https://developer.android.com/studio/releases/build-tools>

## Please Note

This is an automatically updating package. It will download the latest build-tools from dl.google.com/android/repository/build-tools_r`version`-windows.zip and extract aapt.exe. You can find all available versions at <https://dl.google.com/android/repository/repository2-1.xml.>
If you find there is an update available, reinstall using `choco install aapt --force` and please contact the maintainer(s) to let them know the package is updated so that a new version number can be pushed.

## Package Parameters

`/Channel:['stable'|'beta'|'dev'|'canary']` - Specify from which channel to download. Default = stable. Also defaults to stable if nonexistant, null, or whitespace. Channel:stable will download the latest full release.
Example: `choco install aapt2 --params '/Channel:beta'`
