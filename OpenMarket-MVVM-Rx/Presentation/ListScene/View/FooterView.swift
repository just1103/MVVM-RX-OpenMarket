import UIKit
import RxSwift
import RxCocoa

final class FooterView: UICollectionReusableView {
    // MARK: - Properties
    private let bannerPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .systemGray2
        pageControl.currentPageIndicatorTintColor = CustomColor.darkGreenColor
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Methods
    func bind(input: Observable<Int>, indexPath: IndexPath, pageNumber: Int) {
        bannerPageControl.numberOfPages = pageNumber
        if indexPath.section == 0 {
            input
                .subscribe(onNext: { [weak self] currentPage in
                    self?.bannerPageControl.currentPage = currentPage
                })
                .disposed(by: disposeBag)
        } else {
            self.isHidden = true
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
