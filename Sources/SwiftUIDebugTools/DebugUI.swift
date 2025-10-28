#if DEBUG
import SwiftUI

public struct DebugControlPanel: View {
    @ObservedObject var manager = DebugManager.shared
    @State private var isExpanded = true
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    Text("Debug Tools")
                        .font(.headline)
                    Spacer()
                }
                .padding(12)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Random Colors", isOn: $manager.randomColorsEnabled)
                    Toggle("Show Dimensions", isOn: $manager.showDimensionsEnabled)
                    Toggle("Performance Monitor", isOn: $manager.showPerformanceEnabled)
                    
                    Text("Tap any view to inspect")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
            }
        }
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}

struct PerformanceOverlay: View {
    @ObservedObject var monitor = PerformanceMonitor.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "speedometer")
                Text("Performance")
                    .font(.caption.bold())
            }
            
            HStack {
                Text("FPS:")
                    .font(.caption2)
                Text(String(format: "%.1f", monitor.fps))
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(fpsColor)
            }
            
            HStack {
                Text("Frame:")
                    .font(.caption2)
                Text(String(format: "%.2f ms", monitor.frameTime))
                    .font(.caption2.monospacedDigit())
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    var fpsColor: Color {
        if monitor.fps >= 55 { return .green }
        else if monitor.fps >= 30 { return .yellow }
        else { return .red }
    }
}

struct InspectorPanel: View {
    @ObservedObject var manager = DebugManager.shared
    
    var body: some View {
        if manager.showInspector, let viewInfo = manager.inspectedView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("View Inspector")
                        .font(.headline)
                    Spacer()
                    Button(action: { manager.showInspector = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                Text(viewInfo.description)
                    .font(.system(.caption, design: .monospaced))
                
                Text("Tapped at: \(viewInfo.timestamp.formatted(date: .omitted, time: .standard))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.black.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

struct DebugOverlay: View {
    @ObservedObject var manager = DebugManager.shared
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    DebugControlPanel()
                    Spacer()
                    if manager.showPerformanceEnabled {
                        PerformanceOverlay()
                    }
                }
                .padding()
                
                Spacer()
                
                InspectorPanel()
            }
        }
        .allowsHitTesting(true)
    }
}

struct DebugEnvironmentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environmentObject(DebugManager.shared)
            .overlay(DebugOverlay())
    }
}

public extension View {
    func debugEnvironment() -> some View {
        #if DEBUG
        modifier(DebugEnvironmentModifier())
        #else
        self
        #endif
    }
}
#endif
