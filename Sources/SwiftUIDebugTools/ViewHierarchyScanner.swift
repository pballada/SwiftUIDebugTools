#if DEBUG
import UIKit

// MARK: - View Hierarchy Scanner
final class ViewHierarchyScanner {

    /// Get all views in the hierarchy starting from root
    static func getAllViews(from rootView: UIView) -> [UIView] {
        var allViews: [UIView] = []

        func traverse(_ view: UIView) {
            allViews.append(view)
            for subview in view.subviews {
                traverse(subview)
            }
        }

        traverse(rootView)
        return allViews
    }

    /// Filter to only meaningful views (not containers or debug UI)
    static func getMeaningfulViews(from views: [UIView]) -> [UIView] {
        return views.filter { isMeaningfulView($0) && !isDebugUIView($0) }
    }

    /// Check if view is part of the debug UI (should be excluded)
    static func isDebugUIView(_ view: UIView) -> Bool {
        let debugIdentifiers = [
            "debugtools.controlpanel",
            "debugtools.inspector",
            "debugtools.performance"
        ]

        // Check this view
        if let identifier = view.accessibilityIdentifier,
           debugIdentifiers.contains(identifier) {
            return true
        }

        // Check ancestors
        var current = view.superview
        while let parent = current {
            if let identifier = parent.accessibilityIdentifier,
               debugIdentifiers.contains(identifier) {
                return true
            }
            current = parent.superview
        }

        return false
    }

    /// Determine if a view is meaningful (has content) vs just a container
    static func isMeaningfulView(_ view: UIView) -> Bool {
        let typeName = String(describing: type(of: view))

        // Skip known container/wrapper types
        let containerPatterns = [
            "_UIHostingView",
            "UITransitionView",
            "_UILayoutGuide",
            "UIViewControllerWrapperView",
            "UIInputSetContainerView",
            "UIDropShadowView",
            "_UINavigationBarLargeTitleView"
        ]

        for pattern in containerPatterns {
            if typeName.contains(pattern) {
                return false
            }
        }

        // Skip if too small
        if view.bounds.width < 4 || view.bounds.height < 4 {
            return false
        }

        // Skip if hidden or fully transparent
        if view.isHidden || view.alpha == 0 {
            return false
        }

        // Include if has visual content indicators
        if view.backgroundColor != nil && view.backgroundColor != .clear {
            return true
        }

        // Include specific UIKit types that likely have content
        let includeTypes = [
            "UILabel",
            "UIImageView",
            "UIButton",
            "UITextField",
            "UITextView",
            "UISwitch",
            "UISlider",
            "UIProgressView",
            "UISegmentedControl",
            "UIStackView"
        ]

        if includeTypes.contains(where: { typeName.contains($0) }) {
            return true
        }

        // Include SwiftUI-rendered content views
        if typeName.contains("DisplayList") ||
           typeName.contains("CGDrawingView") ||
           typeName.contains("_UIGraphicsView") {
            return true
        }

        // Include views with non-clear layer content
        if let bgColor = view.layer.backgroundColor,
           UIColor(cgColor: bgColor) != .clear {
            return true
        }

        // Include views with meaningful sublayers
        if let sublayers = view.layer.sublayers,
           sublayers.contains(where: { $0.backgroundColor != nil || $0.contents != nil }) {
            return true
        }

        // Default: include if has no subviews (leaf node)
        return view.subviews.isEmpty
    }
}

#endif
