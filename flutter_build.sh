#!/bin/bash
set -e  # Exit on any error

echo "Starting Flutter setup..."

# Download Flutter SDK
FLUTTER_VERSION=3.22.0
echo "Downloading Flutter SDK version $FLUTTER_VERSION"
curl -Lo flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# Extract Flutter SDK
echo "Extracting Flutter SDK..."
tar -xf flutter.tar.xz

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Verify Flutter is working
echo "Verifying Flutter installation..."
flutter --version
flutter doctor

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
