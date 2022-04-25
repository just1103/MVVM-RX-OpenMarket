import UIKit

extension UILabel {  
    func strikeThrough(text: String) {
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        self.attributedText = attributeString
    }
}
