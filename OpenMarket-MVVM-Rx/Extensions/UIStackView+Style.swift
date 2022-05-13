import UIKit

extension UIStackView {
    func style(axis: NSLayoutConstraint.Axis,
               alignment: UIStackView.Alignment,
               distribution: UIStackView.Distribution,
               spacing: CGFloat = .zero,
               verticalInset: CGFloat = .zero,
               horizontalInset: CGFloat = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        self.layoutMargins = UIEdgeInsets(top: verticalInset,
                                          left: horizontalInset,
                                          bottom: verticalInset,
                                          right: horizontalInset)
        self.isLayoutMarginsRelativeArrangement = true
    }
}
