#!/usr/bin/env bash
# StackDialer Real Native Android APK Build Script
set -e

echo "=== Building StackDialer Android APK ==="
echo "1. Checking Flutter SDK..."
flutter doctor -v

echo "2. Installing Flutter dependencies..."
flutter pub get

echo "3. Building Release APK..."
flutter build apk --release --split-per-abi=false

echo "=== Build Complete! ==="
echo "Your installable APK is located at:"
echo "build/app/outputs/flutter-apk/app-release.apk"
