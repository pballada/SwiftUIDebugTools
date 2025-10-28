#if DEBUG
import SwiftUI

public class DebugManager: ObservableObject {
    @Published public var randomColorsEnabled = false
    @Published public var showDimensionsEnabled = false
    @Published public var showPerformanceEnabled = false
    @Published public var inspectedView: ViewInfo?
    @Published public var showInspector = false
    
    public static let shared = DebugManager()
    
    private init() {}
    
    public func inspectView(_ info: ViewInfo) {
        inspectedView = info
        showInspector = true
    }
}
#endif