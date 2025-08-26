#!/bin/bash

# Download and install Flutter SDK
FLUTTER_VERSION=stable
curl -Lo flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz

# Extract Flutter SDK
tar xf flutter.tar.xz

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Enable web support
flutter config --enable-web

# Verify Flutter installation
flutter --version

# Get dependencies
flutter pub get

# Build web app with environment variables
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ADMIN_EMAIL=$ADMIN_EMAIL
