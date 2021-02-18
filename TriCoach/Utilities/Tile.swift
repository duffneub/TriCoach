//
//  Tile.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/10/21.
//

import SwiftUI

extension View {
    func tile(padding: CGFloat? = nil) -> some View {
        modifier(Tile(padding: padding))
    }
}

private struct Tile : ViewModifier {
    var padding: CGFloat?

    func body(content: Content) -> some View {
        TileView(padding: padding) {
            content
        }
    }
}

private struct TileView <Content : View> : View {
    var padding: CGFloat?
    var content: () -> Content
    
    init(padding: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
        .padding(.all, padding)
        .background(Color.tileBackground)
        .cornerRadius(cornerRadius)
        .shadow(color: shadowColor, radius: shadowRadius, x: shadowPosition.x, y: shadowPosition.y)
    }
    
    // MARK: - View Constants
    
    private let cornerRadius: CGFloat = 12
    
    private let shadowColor = Color(white: 0, opacity: 0.1)
    private let shadowRadius: CGFloat = 1
    private let shadowPosition: CGPoint = .init(x: 0, y: 2)
}



extension Color {
    fileprivate static var tileBackground: Color {
        Color(.tileBackground)
    }
}

extension UIColor {
    fileprivate static var tileBackground: UIColor {
        .init { traits in
            traits.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : .white
        }
    }
}
