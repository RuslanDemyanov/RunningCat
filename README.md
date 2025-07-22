# RunningCatMenuBar 🐱

A delightful macOS status bar application that displays a running cat animation in your menu bar. The cat's running speed dynamically changes based on your Mac's CPU usage - the higher the CPU load, the faster the cat runs!

![Cat Animation](https://img.shields.io/badge/Animation-Lottie-blue)
![Platform](https://img.shields.io/badge/Platform-macOS%2012+-green)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)

## Features

🎬 **Lottie Animation**: Beautiful, smooth cat walking/running animation  
📊 **Real-time CPU Monitoring**: Updates every 0.5 seconds for responsive animation  
⚡ **Dynamic Speed**: Cat speed reflects CPU usage (sleeping → walking → jogging → running → sprinting)  
🖱️ **Interactive Popover**: Click the cat to see detailed CPU information  
🌙 **Dark Mode Support**: Adapts to your system's appearance  
🔋 **Lightweight**: Minimal resource usage  

## Cat Speed Mapping

| CPU Usage | Cat State | Animation Speed | Description |
|-----------|-----------|-----------------|-------------|
| 0-5% | 😴 Sleeping | 0.1x | Almost idle, very slow |
| 5-15% | 🚶‍♂️ Walking slowly | 0.3-0.6x | Low usage, leisurely pace |
| 15-30% | 🚶 Walking | 0.6-0.9x | Normal walking |
| 30-60% | 🏃‍♂️ Jogging | 0.9-1.65x | Moderate usage, picking up pace |
| 60-85% | 🏃 Running | 1.65-2.65x | High usage, running fast |
| 85-100% | 💨 Sprinting | 2.65-4.0x+ | Maximum effort! |

## Installation

### Prerequisites

- macOS 12.0 or later
- Swift 5.9 or later
- Git (for cloning)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd running_cpu/RunningCatMenuBar
   ```

2. **Build and run**
   ```bash
   swift run
   ```

That's it! The cat will appear in your menu bar and start monitoring your CPU.

### Building for Release

```bash
swift build -c release
```

The executable will be located at `.build/release/RunningCatMenuBar`

## Usage

### Basic Operation

1. **Launch the app** - The cat appears in your menu bar
2. **Monitor CPU** - Cat speed automatically adjusts to CPU usage
3. **View details** - Click the cat to see a detailed CPU information popover
4. **Quit** - Multiple options available (see Quit Options section below)

### Menu Bar Behavior

- **Tooltip**: Hover over the cat to see current CPU usage percentage
- **Left-click**: Opens detailed CPU information popover
- **Right-click**: Shows context menu with quit option
- **Animation**: Continuously loops with speed based on real-time CPU usage

### Quit Options

The app provides multiple convenient ways to quit:

1. **Keyboard Shortcuts**:
   - `⌘Q` (Command+Q) - Global quit shortcut
   - `ESC` - Close popover (when open)

2. **Right-click Context Menu**:
   - Right-click the cat in menu bar
   - Select "Quit RunningCat"

3. **Popover Buttons**:
   - Click cat → "Quit" button in top-right
   - Click cat → "Quit App" button at bottom

4. **Force Quit**:
   - Activity Monitor → RunningCatMenuBar → Force Quit
   - `⌘⌥ESC` → Force Quit Applications

5. **Terminal**:
   - `killall RunningCatMenuBar`
   - `pkill -f RunningCat`

### Popover Information

The popover displays:
- Current CPU usage percentage
- Visual progress bar with color coding (green/yellow/red)
- Current cat animation speed
- Cat's current state description
- Performance thresholds guide
- Quick action buttons (Quit App, Close Panel)

## Project Structure

```
RunningCatMenuBar/
├── Package.swift                 # Swift Package Manager configuration
├── Sources/RunningCatMenuBar/
│   ├── main.swift               # Main entry point
│   ├── StatusBarController.swift # Menu bar management
│   ├── CPUMonitor.swift         # CPU usage monitoring
│   ├── LottieStatusBarView.swift # Lottie animation view
│   ├── CPUDetailView.swift      # SwiftUI popover content
│   └── Resources/
│       └── cat walking.json     # Lottie animation file
└── README.md
```

## Technical Details

### Dependencies

- **Lottie iOS**: For smooth vector animations
- **Combine**: For reactive CPU monitoring
- **SwiftUI**: For the detail popover interface
- **AppKit**: For menu bar integration

### CPU Monitoring

The app uses macOS system APIs to monitor CPU usage:
- `host_processor_info()` for real-time CPU statistics
- Updates every 0.5 seconds for smooth animation transitions
- Calculates usage across all CPU cores
- Smoothed transitions to prevent jarring speed changes

### Performance

- **Memory usage**: < 10MB typical
- **CPU overhead**: < 1% on modern Macs
- **Battery impact**: Minimal (designed for always-on use)

## Customization

### Animation Speed

Edit `LottieStatusBarView.swift` to modify the speed mapping:

```swift
static func mapCPUToAnimationSpeed(_ cpuUsage: Double) -> CGFloat {
    // Customize speed ranges here
}
```

### Update Frequency

Modify the timer interval in `CPUMonitor.swift`:

```swift
timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
```

### Visual Appearance

The app automatically adapts to dark/light mode. Customize colors in `CPUDetailView.swift`.

## Troubleshooting

### Cat Not Animating

1. Check if Lottie dependency is properly resolved
2. Verify `cat walking.json` is in the Resources folder
3. Check console output for animation loading errors

### High CPU Usage from App

1. Increase monitoring interval (default: 0.5s)
2. Check for memory leaks in Activity Monitor
3. Restart the application

### Animation Stuttering

1. Close other CPU-intensive applications
2. Check if running on battery power (some throttling may occur)
3. Verify macOS version compatibility

## Building App Bundle

To create a distributable `.app` bundle:

```bash
# Build release version
swift build -c release

# Create app structure
mkdir -p RunningCatMenuBar.app/Contents/{MacOS,Resources}

# Copy executable
cp .build/release/RunningCatMenuBar RunningCatMenuBar.app/Contents/MacOS/

# Copy resources
cp -r Sources/RunningCatMenuBar/Resources/* RunningCatMenuBar.app/Contents/Resources/

# Create Info.plist
cat > RunningCatMenuBar.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">