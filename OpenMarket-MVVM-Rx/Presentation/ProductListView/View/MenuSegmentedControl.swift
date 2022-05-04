//import UIKit
//
//class MenuSegmentedControl: UIView {
//    enum MenuButton {
//        case table
//        case grid
//        
//        var titleLabelText: String {
//            switch self {
//            case .table:
//                return "Table로 보기"
//            case .grid:
//                return "Grid로 보기"
//            }
//        }
//    }
//    
////    private var buttonTitles: [String]
//    private var gridButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle(MenuButton.grid.titleLabelText, for: .normal)
//        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
//        button.setTitleColor(.label, for: .normal)
////        button.setTitleColor(.systemRed, for: .selected) // TODO: 확인
//    }()
//    
//    private var tableButton: UIButton!
//    private var selectorView: UIView!
//    
//    private(set) var selectedIndex: Int = 0
//    
////    convenience init(buttonTitles: [String]) {
////        self.buttonTitles = buttonTitles
////    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        self.backgroundColor = UIColor.white
//        updateView()
//    }
//    
//    private func updateView() {
//        createButton()
//        configSelectorView()
//        configStackView()
//    }
//    
//    private func createButton() {
//        gridButton = UIButton()
//        tableButton = UIButton()
//        buttonTitles =
//
//    }
//    
//    private func configSelectorView() {
//        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
//        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: selectorWidth, height: 2))
//        selectorView.backgroundColor = selectorViewColor
//        addSubview(selectorView)
//    }
//    
//    private func configStackView() {
//        let stack = UIStackView(arrangedSubviews: buttons)
//        stack.axis = .horizontal
//        stack.alignment = .fill
//        stack.distribution = .fillEqually
//        addSubview(stack)
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//    } 
//}
