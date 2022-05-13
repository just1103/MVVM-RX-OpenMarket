import UIKit

extension UILabel {  
    func strikeThrough(text: String) {
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        self.attributedText = attributeString
    }
    
    func style(textAlignment: NSTextAlignment,
               font: UIFont,
               textColor: UIColor = .black,
               numberOfLines: Int = 1) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = textAlignment
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
    }
}
