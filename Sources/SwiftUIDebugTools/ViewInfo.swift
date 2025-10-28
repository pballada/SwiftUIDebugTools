#if DEBUG
import SwiftUI

public struct ViewInfo: Identifiable {
    public let id = UUID()
    public let size: CGSize
    public let position: CGPoint
    public let frame: CGRect
    public let timestamp: Date
    
    public var description: String {
        """
        Size: \(Int(size.width)) × \(Int(size.height))
        Position: (\(Int(position.x)), \(Int(position.y)))
        Frame: \(Int(frame.origin.x)), \(Int(frame.origin.y)), \(Int(frame.width)), \(Int(frame.height))
        """
    }
}
#endif
