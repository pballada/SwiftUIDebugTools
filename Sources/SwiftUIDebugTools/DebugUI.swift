#if DEBUG
import SwiftUI

// MARK: - Grid and Rulers Overlay (Minimalist Apple Style)
struct GridAndRulersOverlay: View {
    let gridSize: GridSize
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical grid lines
                ForEach(0..<Int(geometry.size.width / gridSize.spacing) + 1, id: \.self) { i in
                    let x = CGFloat(i) * gridSize.spacing
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(
                        i % 5 == 0 ? Color.blue.opacity(0.4) : Color.blue.opacity(0.15),
                        lineWidth: i % 5 == 0 ? 0.5 : 0.3
                    )
                }
                
                // Horizontal grid lines
                ForEach(0..<Int(geometry.size.height / gridSize.spacing) + 1, id: \.self) { i in
                    let y = CGFloat(i) * gridSize.spacing
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(
                        i % 5 == 0 ? Color.blue.opacity(0.4) : Color.blue.opacity(0.15),
                        lineWidth: i % 5 == 0 ? 0.5 : 0.3
                    )
                }
                
                // Top ruler (minimalist)
                HStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.width / gridSize.spacing) + 1, id: \.self) { i in
                        let showLabel = i % 5 == 0
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.primary.opacity(0.3))
                                .frame(width: 0.5, height: showLabel ? 6 : 3)
                            if showLabel {
                                Text("\(i * Int(gridSize.spacing))")
                                    .font(.system(size: 7, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                        }
                        .frame(width: gridSize.spacing, alignment: .leading)
                    }
                }
                .frame(height: 16)
                .background(.ultraThinMaterial)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Left ruler (minimalist)
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / gridSize.spacing) + 1, id: \.self) { i in
                        let showLabel = i % 5 == 0
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.primary.opacity(0.3))
                                .frame(width: showLabel ? 6 : 3, height: 0.5)
                            if showLabel {
                                Text("\(i * Int(gridSize.spacing))")
                                    .font(.system(size: 7, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                        }
                        .frame(height: gridSize.spacing, alignment: .top)
                    }
                }
                .frame(width: 28)
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Performance Overlay
struct PerformanceOverlay: View {
    @ObservedObject var monitor = PerformanceMonitor.shared
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FPS")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                Text(String(format: "%.0f", monitor.fps))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(fpsColor)
            }
            
            Divider()
                .frame(height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("MS")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f", monitor.frameTime))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .accessibilityIdentifier("debugtools.performance")
    }

    var fpsColor: Color {
        if monitor.fps >= 55 { return .green }
        else if monitor.fps >= 30 { return .orange }
        else { return .red }
    }
}

// MARK: - Inspector Panel
struct InspectorPanel: View {
    @ObservedObject var manager = DebugManager.shared
    
    var body: some View {
        if manager.showInspector, let viewInfo = manager.inspectedView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("View Inspector")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Tapped at \(viewInfo.timestamp.formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            manager.showInspector = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(label: "Size", value: "\(Int(viewInfo.size.width)) × \(Int(viewInfo.size.height))")
                    InfoRow(label: "Position", value: "(\(Int(viewInfo.position.x)), \(Int(viewInfo.position.y)))")
                    InfoRow(label: "Frame", value: "x:\(Int(viewInfo.frame.origin.x)) y:\(Int(viewInfo.frame.origin.y)) w:\(Int(viewInfo.frame.width)) h:\(Int(viewInfo.frame.height))")
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: -2)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityIdentifier("debugtools.inspector")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}
// MARK: - Debug Control Panel (Bottom Sheet Style)
struct DebugControlPanel: View {
    @ObservedObject var manager = DebugManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Performance overlay at top if enabled
            if manager.showPerformanceEnabled {
                PerformanceOverlay()
                    .padding(.bottom, 16)
            }
            
            VStack(spacing: 16) {
                // Random Colors
                ToggleRow(
                    icon: "paintpalette.fill",
                    title: "Random Colors",
                    isOn: $manager.randomColorsEnabled
                )
                
                // Dimensions
                ToggleRow(
                    icon: "ruler.fill",
                    title: "Show Dimensions",
                    isOn: $manager.showDimensionsEnabled
                )
                
                // Performance
                ToggleRow(
                    icon: "speedometer",
                    title: "Performance Monitor",
                    isOn: $manager.showPerformanceEnabled
                )
                
                // Grid & Rulers
                ToggleRow(
                    icon: "grid",
                    title: "Grid & Rulers",
                    isOn: $manager.showGridAndRulersEnabled
                )

                // Grid Size Picker
                if manager.showGridAndRulersEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grid Size")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Picker("Grid Size", selection: $manager.gridSize) {
                            ForEach(GridSize.allCases, id: \.self) { size in
                                Text(size.description).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 20)
            
            // Helper text
            Text("Tap any view to inspect")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.top, 20)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.2), radius: 20, y: -5)
        .accessibilityIdentifier("debugtools.controlpanel")
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Debug Overlay Container
struct DebugOverlay: View {
    @ObservedObject var manager = DebugManager.shared
    
    var body: some View {
        ZStack {
            // Grid and rulers behind everything
            if manager.isVisible && manager.showGridAndRulersEnabled {
                GridAndRulersOverlay(gridSize: manager.gridSize)
            }
            
            VStack {
                Spacer()
                
                // Inspector panel (above control panel)
                if manager.isVisible {
                    InspectorPanel()
                }
                
                // Bottom sheet control panel
                if manager.isVisible {
                    DebugControlPanel()
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: manager.isVisible)
        }
    }
}

// MARK: - Debug Environment Modifier
struct DebugEnvironmentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environmentObject(DebugManager.shared)
            .overlay(DebugOverlay())
            .background(
                WindowSceneReader { windowScene in
                    AutoDebugCoordinator.shared.activate(in: windowScene)
                }
            )
            #if targetEnvironment(simulator)
            .background(KeyboardShortcutHandler())
            #endif
    }
}

public extension View {
    func debugEnvironment() -> some View {
        modifier(DebugEnvironmentModifier())
    }
}

// MARK: - Helper for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#endif
