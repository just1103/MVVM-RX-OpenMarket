import UIKit
import RxSwift
import RxCocoa

class FooterView: UICollectionReusableView {
    // MARK: - Nested Type
    enum Design {
        static let darkGreenColor = #colorLiteral(red: 0.137904644, green: 0.3246459067, blue: 0.2771841288, alpha: 1)
    }
    
    private let disposeBag = DisposeBag()
    
    private let bannerPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .systemGray2
        pageControl.currentPageIndicatorTintColor = Design.darkGreenColor
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(input: Observable<Int>, indexPath: IndexPath, pageNumber: Int) {
        bannerPageControl.numberOfPages = pageNumber
        if indexPath.section == 1 {
            self.isHidden = true
        } else {
            input
                .subscribe(onNext: { [weak self] currentPage in
                    self?.bannerPageControl.currentPage = currentPage
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func configureUI() {
        addSubview(bannerPageControl)
        NSLayoutConstraint.activate([
            bannerPageControl.topAnchor.constraint(equalTo: topAnchor),
            bannerPageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            bannerPageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerPageControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
