#if DEBUG
import SwiftUI

// MARK: - View Info
struct ViewInfo: Identifiable {
    let id = UUID()
    let size: CGSize
    let position: CGPoint
    let frame: CGRect
    let timestamp: Date
    
    var description: String {
        """
        Size: \(Int(size.width)) × \(Int(size.height))
        Position: (\(Int(position.x)), \(Int(position.y)))
        Frame: \(Int(frame.origin.x)), \(Int(frame.origin.y)), \(Int(frame.width)), \(Int(frame.height))
        """
    }
}
#endif
