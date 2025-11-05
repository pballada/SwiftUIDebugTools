#if DEBUG
import SwiftUI


// MARK: - Inspector Panel
struct InspectorPanel: View {
   @ObservedObject var manager = DebugManager.shared
   
   var body: some View {
       if manager.showInspector, let viewInfo = manager.inspectedView {
           VStack(alignment: .leading, spacing: 12) {
               HStack {
                   Text("View Inspector")
                       .font(.headline)
                   Spacer()
                   Button(action: { manager.showInspector = false }) {
                       Image(systemName: "xmark.circle.fill")
                           .foregroundColor(.white)
                   }
               }
               
               Text(viewInfo.description)
                   .font(.system(.caption, design: .monospaced))
               
               Text("Tapped at: \(viewInfo.timestamp.formatted(date: .omitted, time: .standard))")
                   .font(.caption2)
                   .foregroundColor(.gray)
           }
           .padding()
           .background(Color.black.opacity(0.9))
           .foregroundColor(.white)
           .cornerRadius(12)
           .shadow(radius: 10)
           .padding()
           .transition(.move(edge: .bottom).combined(with: .opacity))
       }
   }
}


// MARK: - Grid and Rulers Overlay
struct GridAndRulersOverlay: View {
    let gridSpacing: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical grid lines
                ForEach(0..<Int(geometry.size.width / gridSpacing) + 1, id: \.self) { i in
                    Path { path in
                        let x = CGFloat(i) * gridSpacing
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                }
                
                // Horizontal grid lines
                ForEach(0..<Int(geometry.size.height / gridSpacing) + 1, id: \.self) { i in
                    Path { path in
                        let y = CGFloat(i) * gridSpacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                }
                
                // Top ruler
                HStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.width / gridSpacing) + 1, id: \.self) { i in
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 1, height: 8)
                            Text("\(i * Int(gridSpacing))")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(width: gridSpacing, alignment: .leading)
                    }
                }
                .frame(height: 20)
                .background(Color.black.opacity(0.5))
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Left ruler
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / gridSpacing) + 1, id: \.self) { i in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 8, height: 1)
                            Text("\(i * Int(gridSpacing))")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(height: gridSpacing, alignment: .top)
                    }
                }
                .frame(width: 40)
                .background(Color.black.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Debug Control Panel
struct DebugControlPanel: View {
   @ObservedObject var manager = DebugManager.shared
   @State private var isExpanded = true
   
   var body: some View {
       VStack(alignment: .leading, spacing: 0) {
           // Header
           Button(action: { isExpanded.toggle() }) {
               HStack {
                   Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                   Text("Debug Tools")
                       .font(.headline)
                   Spacer()
               }
               .padding(12)
               .background(Color.black.opacity(0.8))
               .foregroundColor(.white)
           }
           
           // Controls
           if isExpanded {
               VStack(alignment: .leading, spacing: 12) {
                   Toggle("Random Colors", isOn: $manager.randomColorsEnabled)
                   Toggle("Show Dimensions", isOn: $manager.showDimensionsEnabled)
                   Toggle("Performance Monitor", isOn: $manager.showPerformanceEnabled)
                   Toggle("Grid & Rulers", isOn: $manager.showGridAndRulersEnabled)
                   
                   Text("Tap any view to inspect")
                       .font(.caption)
                       .foregroundColor(.gray)
               }
               .padding(12)
               .background(Color.black.opacity(0.7))
               .foregroundColor(.white)
           }
       }
       .cornerRadius(8)
       .shadow(radius: 5)
   }
}

// MARK: - Debug Overlay Container
struct DebugOverlay: View {
   @ObservedObject var manager = DebugManager.shared
   
   var body: some View {
       ZStack {
           // Grid and rulers behind everything
           if manager.showGridAndRulersEnabled {
               GridAndRulersOverlay()
           }
           
           VStack {
               HStack {
                   DebugControlPanel()
                   Spacer()
                   if manager.showPerformanceEnabled {
                       PerformanceOverlay()
                   }
               }
               .padding()
               
               Spacer()
               
               InspectorPanel()
           }
       }
       .allowsHitTesting(true)
   }
}

// MARK: - Debug Environment Modifier
struct DebugEnvironmentModifier: ViewModifier {
   func body(content: Content) -> some View {
       content
           .environmentObject(DebugManager.shared)
           .overlay(DebugOverlay())
   }
}

extension View {
   public func debugEnvironment() -> some View {
       modifier(DebugEnvironmentModifier())
   }
}
#endif
