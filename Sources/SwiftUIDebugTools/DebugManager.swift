#if DEBUG
import SwiftUI

class DebugManager: ObservableObject {
    @Published var randomColorsEnabled = false
    @Published var showDimensionsEnabled = false
    @Published var showPerformanceEnabled = false
    @Published var showGridAndRulersEnabled = false
    @Published var inspectedView: ViewInfo?
    @Published var showInspector = false
    
    static let shared = DebugManager()
    
    private init() {}
    
    func inspectView(_ info: ViewInfo) {
        inspectedView = info
        showInspector = true
    }
}

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
