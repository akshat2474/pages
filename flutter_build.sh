#!/bin/bash
set -e  # Exit on any error

echo "Starting Flutter setup..."

# Use newer Flutter version that includes Dart SDK 3.8.1+
FLUTTER_VERSION=3.24.0
echo "Downloading Flutter SDK version $FLUTTER_VERSION"
curl -Lo flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# Extract Flutter SDK
echo "Extracting Flutter SDK..."
tar -xf flutter.tar.xz

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Verify Flutter and Dart versions
echo "Verifying installation..."
flutter --version
dart --version

# Enable web support
echo "Enabling web support..."
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web app
echo "Building web app..."
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ADMIN_EMAIL=$ADMIN_EMAIL

echo "Build complete!"
