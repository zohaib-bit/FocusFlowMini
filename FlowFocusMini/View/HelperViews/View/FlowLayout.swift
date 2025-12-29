//
//  FlowLayout.swift
//  FlowFocusMini
//
//  Created by o9tech on 09/12/2025.
//

import SwiftUI

// MARK: - Shared FlowLayout (Use in all interest screens)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        let availableWidth = proposal.width ?? 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentRowWidth + spacing + size.width > availableWidth {
                height += size.height + spacing
                currentRowWidth = size.width
            } else {
                currentRowWidth += (currentRowWidth > 0 ? spacing : 0) + size.width
            }
        }
        height += subviews.first?.sizeThatFits(.unspecified).height ?? 0
        return CGSize(width: availableWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += size.height + spacing
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
        }
    }
}
