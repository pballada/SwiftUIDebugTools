//
//  ContentView.swift
//  DebugToolsExample
//
//  Created by Pau on 28/10/25.
//

import SwiftUI
import SwiftUIDebugTools

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Basic Views") {
                    NavigationLink("Simple Layout") {
                        SimpleLayoutExample()
                    }
                    
                    NavigationLink("Complex Layout") {
                        ComplexLayoutExample()
                    }
                }
                
                Section("Interactive") {
                    NavigationLink("List Example") {
                        ListExample()
                    }
                    
                    NavigationLink("Grid Example") {
                        GridExample()
                    }
                }
                
                Section("Performance") {
                    NavigationLink("Animation Test") {
                        AnimationExample()
                    }
                }
            }
            .navigationTitle("Debug Tools Demo")
        }
    }
}

// MARK: - Examples

struct SimpleLayoutExample: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Simple Layout")
                .font(.title)
            
            HStack(spacing: 15) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                    
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                    
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)
                }
            
            Text("Tap any view to inspect its properties")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct ComplexLayoutExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("User Profile")
                            .font(.title2)
                                    Text("@johndoe")
                            .font(.caption)
                            .foregroundColor(.gray)
                                }
                        
                    Spacer()
                    
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 60, height: 60)
                        }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Cards
                ForEach(0..<3) { i in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Card \(i + 1)")
                            .font(.headline)
                                    
                        Text("This is some sample text for card \(i + 1)")
                            .font(.body)
                                    
                        HStack {
                            ForEach(0..<3) { j in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(height: 40)
                                                }
                        }
                            }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    }
            }
            .padding()
        }
    }
}

struct ListExample: View {
    let items = Array(1...20)
    
    var body: some View {
        List(items, id: \.self) { item in
            HStack {
                Image(systemName: "\(item).circle.fill")
                    .foregroundColor(.blue)
                    
                VStack(alignment: .leading) {
                    Text("Item \(item)")
                        .font(.headline)
                            Text("Description for item \(item)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                }
        }
    }
}

struct GridExample: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(0..<12) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.3))
                        .frame(height: 100)
                        .overlay(
                            Text("\(i + 1)")
                                .font(.title)
                                .foregroundColor(.white)
                                        )
                        }
            }
            .padding()
        }
    }
}

struct AnimationExample: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Performance Test")
                .font(.title)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(isAnimating ? 1.5 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            
            HStack(spacing: 20) {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.2), value: isAnimating)
                        }
            }
            
            Button(isAnimating ? "Stop Animations" : "Start Animations") {
                isAnimating.toggle()
            }
            .buttonStyle(.borderedProminent)
            
            Text("Watch the FPS counter above during animation")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
