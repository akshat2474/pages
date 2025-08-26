#!/bin/bash
set -e

echo "Starting Flutter setup..."

# Use Flutter 3.27 or newer for Material 3 support
echo "Downloading Flutter SDK 3.27+"
curl -Lo flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz"

# Extract Flutter SDK
echo "Extracting Flutter SDK..."
tar -xf flutter.tar.xz

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Verify versions
echo "Verifying installation..."
flutter --version
dart --version

# Enable web support
flutter config --enable-web

# Clean and get dependencies
flutter clean
flutter pub get

# Build web app
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ADMIN_EMAIL=$ADMIN_EMAIL

echo "Build complete!"
