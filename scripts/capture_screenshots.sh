#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCREENSHOTS_DIR="$PROJECT_ROOT/fastlane/screenshots/nb-NO"

if [[ -z "${ANDROID_HOME:-}" ]]; then
  ANDROID_HOME="$HOME/Library/Android/sdk"
fi
export PATH="$ANDROID_HOME/platform-tools:$PATH"

usage() {
  echo "Usage: $0 [--device <device_id>] [--platform ios|android] [--frame] [--frame-only] [--help]"
  echo ""
  echo "Options:"
  echo "  --device <id>     Device ID or simulator name (default: first available)"
  echo "  --platform        ios or android (default: ios)"
  echo "  --frame           Run frameit after capturing screenshots"
  echo "  --frame-only      Skip capture, only run framing on existing screenshots"
  echo "  --help            Show this help message"
  exit 0
}

DEVICE=""
PLATFORM="ios"
DO_FRAME=false
FRAME_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --device) DEVICE="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --frame) DO_FRAME=true; shift ;;
    --frame-only) DO_FRAME=true; FRAME_ONLY=true; shift ;;
    --help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$DEVICE" ]]; then
  if [[ "$PLATFORM" == "android" ]]; then
    DEVICE="Pixel 5"
  fi
fi

if [[ ! -f "$PROJECT_ROOT/.env.test" ]] && ! $FRAME_ONLY; then
  echo "ERROR: .env.test not found. Create it with TEST_EMAIL and TEST_PASSWORD."
  exit 1
fi

if ! $FRAME_ONLY; then
  source "$PROJECT_ROOT/.env.test"

  echo "==> Capturing screenshots ($PLATFORM)..."
  cd "$PROJECT_ROOT"

  CMD=(flutter test integration_test/screenshot_test.dart
    --dart-define="TEST_EMAIL=$TEST_EMAIL"
    --dart-define="TEST_PASSWORD=$TEST_PASSWORD"
  )

  if [[ -n "$DEVICE" ]]; then
    CMD+=(-d "$DEVICE")
  fi

  SCREENSHOT_SRC="/tmp/beermonopoly_screenshots"

  if [[ "$PLATFORM" == "android" ]]; then
    ANDROID_PKG="com.beermonopoly.olmonopolet.android"
    mkdir -p "$SCREENSHOT_SRC"
    "${CMD[@]}" 2>&1 | while IFS= read -r line; do
      echo "$line"
      echo "$line" >> /tmp/screenshot_capture.log
      if [[ "$line" == *"Screenshot saved: "* ]]; then
        device_path="${line##*Screenshot saved: }"
        device_path="$(echo "$device_path" | tr -d '\r')"
        filename="$(basename "$device_path")"
        adb exec-out run-as "$ANDROID_PKG" cat "$device_path" > "$SCREENSHOT_SRC/$filename" 2>/dev/null || true
      fi
    done
  else
    "${CMD[@]}" 2>&1 | tee /tmp/screenshot_capture.log
  fi

  echo ""
  echo "==> Copying screenshots to $SCREENSHOTS_DIR..."
  mkdir -p "$SCREENSHOTS_DIR"
  COPIED=0

  if [[ -d "$SCREENSHOT_SRC" ]]; then
    for f in "$SCREENSHOT_SRC"/*.png; do
      [[ -f "$f" ]] || continue
      base="$(basename "$f")"
      if [[ "$base" != *_android.png && "$base" != *_ios.png ]]; then
        base="${base%.png}_${PLATFORM}.png"
      fi
      cp "$f" "$SCREENSHOTS_DIR/$base"
      COPIED=$((COPIED + 1))
    done
    rm -rf "$SCREENSHOT_SRC"
  fi

  if [[ $COPIED -gt 0 ]]; then
    echo "    Copied $COPIED screenshots."
  else
    echo "WARNING: No screenshot files could be copied."
    echo "    Check the test output for 'Screenshot saved:' paths."
  fi
fi

if $DO_FRAME; then
  echo "==> Generating background gradient..."
  mkdir -p "$PROJECT_ROOT/fastlane/backgrounds"
  magick -size 1284x2778 gradient:'#B8860B'-'#3D2600' \
    "$PROJECT_ROOT/fastlane/backgrounds/gradient_gold.png"

  echo "==> Downloading fonts..."
  mkdir -p "$PROJECT_ROOT/fastlane/fonts"
  if [[ ! -f "$PROJECT_ROOT/fastlane/fonts/Roboto-Bold.ttf" ]]; then
    curl -sL -o "$PROJECT_ROOT/fastlane/fonts/Roboto-Bold.ttf" \
      "https://github.com/google/fonts/raw/main/ofl/roboto/Roboto%5Bwdth%2Cwght%5D.ttf"
  fi
  if [[ ! -f "$PROJECT_ROOT/fastlane/fonts/Roboto.ttf" ]]; then
    curl -sL -o "$PROJECT_ROOT/fastlane/fonts/Roboto.ttf" \
      "https://github.com/google/fonts/raw/main/ofl/roboto/Roboto%5Bwdth%2Cwght%5D.ttf"
  fi

  echo "==> Running frameit..."

  FRAMEFILE="$PROJECT_ROOT/fastlane/screenshots/Framefile.json"
  if [[ "$PLATFORM" == "android" ]]; then
    FRAMEFILE="$PROJECT_ROOT/fastlane/screenshots/Framefile_android.json"
  fi
  cp "$FRAMEFILE" "$PROJECT_ROOT/fastlane/screenshots/Framefile.json.bak" 2>/dev/null || true

  if [[ "$PLATFORM" == "ios" ]]; then
    cd "$PROJECT_ROOT/ios"
    bundle exec fastlane screenshots
  else
    cp "$FRAMEFILE" "$PROJECT_ROOT/fastlane/screenshots/Framefile.json"
    cd "$PROJECT_ROOT/android"
    bundle exec fastlane screenshots
    cp "$PROJECT_ROOT/fastlane/screenshots/Framefile.json.bak" "$PROJECT_ROOT/fastlane/screenshots/Framefile.json" 2>/dev/null || true
    rm -f "$PROJECT_ROOT/fastlane/screenshots/Framefile.json.bak"
  fi

  if [[ "$PLATFORM" == "ios" ]]; then
    echo "==> Resizing framed screenshots to 1284x2778 (6.5\")..."
    for f in "$SCREENSHOTS_DIR"/*_framed.png; do
      [[ -f "$f" ]] || continue
      magick "$f" -resize 1284x2778! "$f"
    done
  fi

  if [[ "$PLATFORM" == "ios" ]]; then
    echo "==> Generating iPad 13\" screenshots (2048x2732)..."
    magick -size 2048x2732 gradient:'#B8860B'-'#3D2600' \
      "$PROJECT_ROOT/fastlane/backgrounds/gradient_gold_ipad.png"

    for f in "$SCREENSHOTS_DIR"/*_framed.png; do
      [[ -f "$f" ]] || continue
      base="$(basename "$f" _framed.png)"
      magick "$PROJECT_ROOT/fastlane/backgrounds/gradient_gold_ipad.png" \
        "$f" -gravity center -composite \
        "$SCREENSHOTS_DIR/${base}_ipad.png"
    done
  fi

  echo "==> Done! Framed screenshots are in $SCREENSHOTS_DIR"
else
  echo "    Run with --frame to automatically apply device frames."
  echo "    Or manually: cd ios && bundle exec fastlane screenshots"
fi
