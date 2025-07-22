#!/bin/bash

# run.sh
# Launch script for RunningCatMenuBar

set -e

echo "🐱 Launching RunningCatMenuBar..."
echo "================================"

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Please run this script from the RunningCatMenuBar directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected to find: Package.swift"
    exit 1
fi

echo "✅ Found Package.swift"

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift not found. Please install Xcode or Swift toolchain."
    exit 1
fi

echo "✅ Swift is available"

# Check if already built
if [ ! -d ".build" ]; then
    echo "📦 Building project for the first time..."
    swift build
    echo "✅ Build complete"
else
    echo "📦 Project already built, checking for updates..."
    swift build
fi

# Check if the cat animation file exists
if [ ! -f "Sources/RunningCatMenuBar/Resources/cat walking.json" ]; then
    echo "⚠️  Warning: cat walking.json not found in Resources"
    echo "   The app will use a fallback cat emoji instead"
fi

echo ""
echo "🚀 Starting RunningCatMenuBar..."
echo ""
echo "📋 Usage:"
echo "   • Look for the cat in your menu bar"
echo "   • Cat speed changes with CPU usage"
echo "   • Click the cat for detailed CPU info"
echo "   • Press Ctrl+C here to quit"
echo ""

# Run the application
swift run

echo ""
echo "👋 RunningCatMenuBar stopped"
