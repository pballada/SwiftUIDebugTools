import SwiftUI

#if DEBUG

// MARK: - Performance Monitor
class PerformanceMonitor: ObservableObject {
    @Published var fps: Double = 60.0
    @Published var frameTime: Double = 16.67
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0
    private var accumulatedTime: CFTimeInterval = 0
    
    static let shared = PerformanceMonitor()
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func displayLinkDidFire(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }
        
        let elapsed = displayLink.timestamp - lastTimestamp
        lastTimestamp = displayLink.timestamp
        
        frameCount += 1
        accumulatedTime += elapsed
        
        // Update FPS every 30 frames
        if frameCount >= 30 {
            // Prevent division by zero
            guard accumulatedTime > 0 else {
                frameCount = 0
                accumulatedTime = 0
                return
            }
            
            let newFPS = Double(frameCount) / accumulatedTime
            let newFrameTime = (accumulatedTime / Double(frameCount)) * 1000.0
            
            // Sanity check values
            if newFPS.isFinite && newFPS > 0 && newFPS <= 120 &&
               newFrameTime.isFinite && newFrameTime > 0 && newFrameTime <= 1000 {
                DispatchQueue.main.async {
                    self.fps = newFPS
                    self.frameTime = newFrameTime
                }
            }
            
            frameCount = 0
            accumulatedTime = 0
        }
    }
    
    func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    deinit {
        stopMonitoring()
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

#endif
