#if DEBUG
import UIKit
import SwiftUI
import Combine

// MARK: - Auto Debug Coordinator
/// Coordinates automatic debug overlays for all views without requiring per-view annotation
public final class AutoDebugCoordinator {

    public static let shared = AutoDebugCoordinator()

    private var overlayWindow: DebugOverlayWindow?
    private var displayLink: CADisplayLink?
    private var needsUpdate = false
    private var cancellables = Set<AnyCancellable>()

    // Track color overlays for cleanup
    private var colorOverlays: [ObjectIdentifier: CALayer] = [:]

    private init() {
        setupObservers()
    }

    // MARK: - Public API

    /// Activate auto-debug for a window scene
    public func activate(in windowScene: UIWindowScene) {
        guard overlayWindow == nil else { return }

        // Create overlay window
        let window = DebugOverlayWindow(windowScene: windowScene)
        window.isHidden = false
        overlayWindow = window

        // Add tap gesture for inspection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        window.addGestureRecognizer(tapGesture)

        // Start display link for updates
        startDisplayLink()

        // Initial refresh after a brief delay for layout to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scheduleUpdate()
        }
    }

    /// Schedule an update on next display link cycle
    public func scheduleUpdate() {
        needsUpdate = true
    }

    // MARK: - Private Setup

    private func setupObservers() {
        let manager = DebugManager.shared

        // Observe toggle changes
        manager.$randomColorsEnabled
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)

        manager.$showDimensionsEnabled
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)

        manager.$isVisible
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)

        // Observe orientation changes
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.scheduleUpdate()
                }
            }
            .store(in: &cancellables)
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 5, maximum: 15, preferred: 10)
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func displayLinkFired() {
        guard needsUpdate else { return }
        needsUpdate = false
        refresh()
    }

    // MARK: - Refresh Debug Visuals

    private func refresh() {
        guard let appWindow = getAppWindow(),
              let overlayVC = overlayWindow?.rootViewController as? DebugOverlayViewController else {
            return
        }

        let manager = DebugManager.shared

        // Clear previous visuals
        overlayVC.clearAll()
        clearColorOverlays()

        // Only show visuals when debug panel is visible
        guard manager.isVisible else { return }

        // Get view hierarchy
        let allViews = ViewHierarchyScanner.getAllViews(from: appWindow)
        let meaningfulViews = ViewHierarchyScanner.getMeaningfulViews(from: allViews)

        // Apply random colors
        if manager.randomColorsEnabled {
            applyRandomColors(to: meaningfulViews)
        }

        // Show dimensions
        if manager.showDimensionsEnabled {
            showDimensions(for: meaningfulViews, in: overlayVC)
        }
    }

    // MARK: - Random Colors

    private func applyRandomColors(to views: [UIView]) {
        for view in views {
            let identifier = ObjectIdentifier(view)

            // Create color overlay layer
            let overlay = CALayer()
            overlay.name = "debugColorOverlay"
            overlay.frame = view.bounds
            overlay.backgroundColor = randomColor().cgColor

            view.layer.addSublayer(overlay)
            colorOverlays[identifier] = overlay
        }
    }

    private func clearColorOverlays() {
        for (_, overlay) in colorOverlays {
            overlay.removeFromSuperlayer()
        }
        colorOverlays.removeAll()
    }

    private func randomColor() -> UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 0.3
        )
    }

    // MARK: - Dimensions

    private func showDimensions(for views: [UIView], in overlayVC: DebugOverlayViewController) {
        guard let overlayWindow = overlayWindow else { return }

        for view in views {
            guard let viewWindow = view.window else { continue }

            // Convert frame to overlay coordinates
            let frameInWindow = view.convert(view.bounds, to: viewWindow)
            let frameInOverlay = overlayWindow.convert(frameInWindow, from: viewWindow)

            // Create dimension label
            let label = DimensionLabel()
            label.configure(width: Int(view.bounds.width), height: Int(view.bounds.height))

            // Size and position
            let labelSize = label.sizeThatFits(.zero)
            label.frame = CGRect(
                x: frameInOverlay.midX - labelSize.width / 2,
                y: frameInOverlay.midY - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )

            // Keep label within bounds
            label.frame.origin.x = max(0, min(label.frame.origin.x, overlayVC.view.bounds.width - labelSize.width))
            label.frame.origin.y = max(0, min(label.frame.origin.y, overlayVC.view.bounds.height - labelSize.height))

            overlayVC.labelsContainer.addSubview(label)
        }
    }

    // MARK: - Tap to Inspect

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let appWindow = getAppWindow(),
              let overlayWindow = overlayWindow else { return }

        let manager = DebugManager.shared
        guard manager.isVisible else { return }

        // Get tap location in app window coordinates
        let pointInOverlay = gesture.location(in: overlayWindow)
        let pointInApp = appWindow.convert(pointInOverlay, from: overlayWindow)

        // Find tapped view
        guard let tappedView = appWindow.hitTest(pointInApp, with: nil) else { return }

        // Get view info
        let frameInWindow = tappedView.convert(tappedView.bounds, to: appWindow)

        let viewInfo = ViewInfo(
            size: tappedView.bounds.size,
            position: frameInWindow.origin,
            frame: frameInWindow,
            timestamp: Date()
        )

        manager.inspectView(viewInfo)
    }

    // MARK: - Utilities

    private func getAppWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .windows
            .first { $0 != overlayWindow && !$0.isHidden && $0.windowLevel == .normal }
    }
}

// MARK: - Window Scene Reader
/// Helper to get UIWindowScene from SwiftUI context
struct WindowSceneReader: UIViewRepresentable {
    let onScene: (UIWindowScene) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let scene = view.window?.windowScene {
                onScene(scene)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#endif
