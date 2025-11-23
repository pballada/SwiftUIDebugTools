#if DEBUG
import UIKit

// MARK: - Debug Overlay Window
/// A transparent window that sits above the app for rendering debug visuals
final class DebugOverlayWindow: UIWindow {

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupWindow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        windowLevel = .alert + 100
        backgroundColor = .clear
        isUserInteractionEnabled = true

        let rootVC = DebugOverlayViewController()
        rootViewController = rootVC
    }

    /// Pass through touches to views below when not hitting debug elements
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        // If hit the window itself or the root view, pass through
        if hitView == self || hitView == rootViewController?.view {
            return nil
        }

        return hitView
    }
}

// MARK: - Debug Overlay View Controller
final class DebugOverlayViewController: UIViewController {

    /// Container for dimension labels
    let labelsContainer = UIView()

    /// Container for view borders/outlines
    let bordersContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        // Add containers
        bordersContainer.backgroundColor = .clear
        bordersContainer.isUserInteractionEnabled = false
        view.addSubview(bordersContainer)

        labelsContainer.backgroundColor = .clear
        labelsContainer.isUserInteractionEnabled = false
        view.addSubview(labelsContainer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bordersContainer.frame = view.bounds
        labelsContainer.frame = view.bounds
    }

    /// Clear all debug visuals
    func clearAll() {
        labelsContainer.subviews.forEach { $0.removeFromSuperview() }
        bordersContainer.subviews.forEach { $0.removeFromSuperview() }
        bordersContainer.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}

// MARK: - Dimension Label View
final class DimensionLabel: UIView {

    private let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 4
        clipsToBounds = true

        textLabel.font = .systemFont(ofSize: 10, weight: .bold)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
    }

    func configure(width: Int, height: Int) {
        textLabel.text = "W:\(width) H:\(height)"
        sizeToFit()
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = textLabel.intrinsicContentSize
        return CGSize(width: labelSize.width + 8, height: labelSize.height + 4)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}

#endif
