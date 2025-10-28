#if DEBUG
import SwiftUI
import QuartzCore

public class PerformanceMonitor: ObservableObject {
    @Published public var fps: Double = 60.0
    @Published public var frameTime: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0
    private var accumulatedTime: CFTimeInterval = 0
    
    public static let shared = PerformanceMonitor()
    
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
        
        if frameCount >= 30 {
            DispatchQueue.main.async {
                self.fps = Double(self.frameCount) / self.accumulatedTime
                self.frameTime = (self.accumulatedTime / Double(self.frameCount)) * 1000
            }
            frameCount = 0
            accumulatedTime = 0
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
#endif
