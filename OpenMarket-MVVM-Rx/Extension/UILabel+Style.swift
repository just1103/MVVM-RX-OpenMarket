import UIKit

extension UILabel {  
    func strikeThrough(text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
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
