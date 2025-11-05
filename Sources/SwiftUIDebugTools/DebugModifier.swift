#if DEBUG
import SwiftUI

// MARK: - Debug Modifier
struct DebugModifier: ViewModifier {
    @ObservedObject var manager: DebugManager
    @State private var size: CGSize = .zero
    @State private var position: CGPoint = .zero
    @State private var frame: CGRect = .zero
    
    let randomColor = Color(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1)
    ).opacity(0.3)
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geo.size)
                        .preference(key: PositionPreferenceKey.self, value: geo.frame(in: .global))
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                size = newSize
            }
            .onPreferenceChange(PositionPreferenceKey.self) { newFrame in
                position = newFrame.origin
                frame = newFrame
            }
            .background(manager.randomColorsEnabled ? randomColor : Color.clear)
            .overlay(
                Group {
                    if manager.showDimensionsEnabled {
                        VStack {
                            Text("W: \(Int(size.width))")
                            Text("H: \(Int(size.height))")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                    }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                let viewInfo = ViewInfo(
                    size: size,
                    position: position,
                    frame: frame,
                    timestamp: Date()
                )
                manager.inspectView(viewInfo)
            }
    }
}

// Add these PreferenceKeys
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - View Extension
extension View {
    public func debugView() -> some View {
        modifier(DebugModifier(manager: DebugManager.shared))
    }
}

#endif
