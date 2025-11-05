#if DEBUG
import SwiftUI

// MARK: - Debug Manager
public class DebugManager: ObservableObject {
    @Published public var isVisible = false
    @Published public var randomColorsEnabled = false
    @Published public var showDimensionsEnabled = false
    @Published public var showPerformanceEnabled = false
    @Published public var showGridAndRulersEnabled = false
    @Published public var gridSize: GridSize = .large
    @Published var inspectedView: ViewInfo?
    @Published public var showInspector = false
    
    public static let shared = DebugManager()
    
    private init() {
        setupKeyboardShortcut()
    }
    
    public func toggle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isVisible.toggle()
        }
    }
    
    func inspectView(_ info: ViewInfo) {
        inspectedView = info
        showInspector = true
    }
    
    private func setupKeyboardShortcut() {
        #if targetEnvironment(simulator)
        // Only setup keyboard shortcuts in simulator
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleDebugTools"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.toggle()
        }
        #endif
    }
}

// MARK: - Keyboard Shortcut Handler (Simulator Only)
#if targetEnvironment(simulator)
struct KeyboardShortcutHandler: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = KeyEventView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    class KeyEventView: UIView {
        override var canBecomeFirstResponder: Bool { true }
        
        override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            guard let key = presses.first?.key else {
                super.pressesBegan(presses, with: event)
                return
            }
            
            // Command + Shift + D
            if key.modifierFlags.contains([.command, .shift]) && key.charactersIgnoringModifiers == "d" {
                DebugManager.shared.toggle()
                return
            }
            
            super.pressesBegan(presses, with: event)
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            becomeFirstResponder()
        }
    }
}
#endif

// MARK: - Environment Key
struct DebugManagerKey: EnvironmentKey {
    static let defaultValue = DebugManager.shared
}

extension EnvironmentValues {
    var debugManager: DebugManager {
        get { self[DebugManagerKey.self] }
        set { self[DebugManagerKey.self] = newValue }
    }
}

#endif

