#if DEBUG
import SwiftUI

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
                        .onAppear {
                            updateMetrics(geo)
                        }
                        .onChange(of: geo.size) { _ in
                                updateMetrics(geo)
                        }
                }
            )
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
    
    private func updateMetrics(_ geo: GeometryProxy) {
        size = geo.size
        position = geo.frame(in: .global).origin
        frame = geo.frame(in: .global)
    }
}

public extension View {
    func debugView() -> some View {
        #if DEBUG
        modifier(DebugModifier(manager: DebugManager.shared))
        #else
        self
        #endif
    }
}
#endif
