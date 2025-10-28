# SwiftUIDebugTools

A lightweight debugging library for SwiftUI that helps you visualize layouts, inspect views, and monitor performance.

## Features

- 🎨 **Random Colors**: Highlight all views with random background colors
- 📏 **Dimensions**: Display width and height for each view
- ⚡ **Performance Monitor**: Real-time FPS and frame time tracking
- 🔍 **Tap to Inspect**: Tap any view to see detailed information
- 🛡️ **Debug-only**: Zero overhead in release builds

## Installation

### Swift Package Manager

Add this to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUIDebugTools.git", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies > paste the repository URL

## Usage
```swift
import SwiftUI
import SwiftUIDebugTools

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .debugEnvironment() // Add this!
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello")
                .debugView() // Add to views you want to debug
            
            Rectangle()
                .frame(width: 100, height: 100)
                .debugView()
        }
        .debugView()
    }
}
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+

## License

MIT