import UIKit
import RxSwift
import RxCocoa

class ProductListViewController: UIViewController {
    // MARK: - Nested Types
    enum Design {
        static let bgcolor = #colorLiteral(red: 0.9524367452, green: 0.9455882907, blue: 0.9387311935, alpha: 1)
        static let lightGreenColor = #colorLiteral(red: 0.5567998886, green: 0.7133290172, blue: 0.6062341332, alpha: 1)
        static let darkGreenColor = #colorLiteral(red: 0.137904644, green: 0.3246459067, blue: 0.2771841288, alpha: 1)
        static let veryDarkGreenColor = #colorLiteral(red: 0.04371468723, green: 0.1676974297, blue: 0.1483464539, alpha: 1)
    }
    
    enum SectionKind: Int {
        case banner
        case list
        
        var columnCount: Int {
            switch self {
            case .banner:
                return 1
            case .list:
                if ProductListViewController.isGrid {
                    return 2
                } else {
                    return 1
                }
            }
        }
        
        func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .banner:
                return .groupPagingCentered
            case .list:
                return .none
            }
        }
    }
        
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let listRefreshButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.backgroundColor = Design.lightGreenColor
        button.setTitle("새로 등록된 상품을 확인하려면 여기를 탭해주세요.", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.isHidden = true
        return button
    }()
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var menuSegmentedControl: MenuSegmentedControl!
    private var dataSource: DiffableDataSource!
    private var snapshot: NSDiffableDataSourceSnapshot<SectionKind, UniqueProduct>!
    private var viewModel: ProductListViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let cellDidScroll = PublishSubject<IndexPath>()
//    private let cellDidSelect: PublishSubject<IndexPath> = .init()
    private let disposeBag = DisposeBag()

    // TODO: ViewModel이 가지고 있도록 변경
    private static var isGrid: Bool = true
    private var currentBannerPage: Int = 0
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, UniqueProduct>
    typealias BannerCellRegistration = UICollectionView.CellRegistration<BannerCell, UniqueProduct>
    typealias TableListCellRegistration = UICollectionView.CellRegistration<TableListCell, UniqueProduct>
    typealias GridListCellRegistration = UICollectionView.CellRegistration<GridListCell, UniqueProduct>
    
    // MARK: - Initializer
    convenience init(viewModel: ProductListViewModel, menuSegmentedControl: MenuSegmentedControl) {
        self.init()
        self.viewModel = viewModel
        self.menuSegmentedControl = menuSegmentedControl
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCellRegistrationAndDataSource()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureStackView()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = Design.darkGreenColor
        navigationItem.titleView = menuSegmentedControl

        navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = false
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationItem.titleView?.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor,
                                                           constant: 30).isActive = true
        navigationItem.titleView?.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor,
                                                            constant: -30).isActive = true
    }
    
    private func configureStackView() {
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubview(listRefreshButton)
        containerStackView.addArrangedSubview(collectionView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
        
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Design.bgcolor
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                print("알 수 없는 Section")
                return nil
            }
            let screenWidth = UIScreen.main.bounds.width
            let estimatedHeight = NSCollectionLayoutDimension.estimated(screenWidth) // 300으로 주면 TableList 짤림
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: estimatedHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: estimatedHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: sectionKind.columnCount)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
            
            return section
        }
        return layout
    }
    
    private func configureCellRegistrationAndDataSource() {
        let bannerCellRegistration = BannerCellRegistration { cell, _, product in
            cell.apply(imageURL: product.product.thumbnail)
        }
        let tableListCellRegistration = TableListCellRegistration { cell, _, product in
            cell.apply(data: product.product)
        }
        let gridListCellRegistration = GridListCellRegistration { cell, _, product in
            cell.apply(data: product.product)
        }
        
        dataSource = DiffableDataSource(collectionView: collectionView,
                                        cellProvider: { collectionView, indexPath, product in
            guard let sectionKind = SectionKind(rawValue: indexPath.section) else {
                return UICollectionViewCell()
            }
            
            switch sectionKind {
            case .banner:
                return  collectionView.dequeueConfiguredReusableCell(using: bannerCellRegistration,
                                                                     for: indexPath,
                                                                     item: product)
            case .list:
                switch ProductListViewController.isGrid {
                case true:
                    return collectionView.dequeueConfiguredReusableCell(using: gridListCellRegistration,
                                                                        for: indexPath,
                                                                        item: product)
                case false:
                    return collectionView.dequeueConfiguredReusableCell(using: tableListCellRegistration,
                                                                        for: indexPath,
                                                                        item: product)
                }
            }
        })
    }
}
    
// MARK: - Rx Binding Methods
extension ProductListViewController {
    private func bind() {
        let input = ProductListViewModel.Input(invokedViewDidLoad: invokedViewDidLoad.asObservable(),
                                               listRefreshButtonDidTap: listRefreshButton.rx.tap.asObservable(),
                                               cellDidScroll: cellDidScroll.asObservable())
        let output = viewModel.transform(input)

        configureItemsWith(output.products)
        showListRefreshButton(output.newProductDidPost)
        configureNewPostedItemsWith(output.newPostedProducts)
        configureNextPageItemsWith(output.nextPageProducts)
    }
    
    private func configureItemsWith(_ listProducts: Observable<[Product]>) {        
        listProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawBannerAndList(with: products)
            })
            .disposed(by: disposeBag)
    }
    
    private func drawBannerAndList(with products: [Product]) {
        // TODO: Banner 관련 별도 메서드로 구분 (사용 중에 배너가 바뀌는 게 어색함)
        let recentBargainProducts = products.filter { product in
            product.discountedPrice != 0
        }
        let bannerProductsCount = 5
        let bannerProducts = Array(recentBargainProducts[0..<bannerProductsCount])
        
        if snapshot == nil {
            // FIXME: 동일한 프로덕트가 다른 섹션에 들어가면 에러 발생
            configureInitialSnapshotWith(listProducts: makeHashable(from: products),
                                         bannerProducts: makeHashable(from: bannerProducts))
        } else {
            applySnapshotWith(listProducts: makeHashable(from: products))
        }
//                self.autoScrollBannerTimer(with: 2, productCount: bannerProductsCount) // FIXME: 위로 자동 scroll됨
    }
    
    private func configureInitialSnapshotWith(listProducts: [UniqueProduct], bannerProducts: [UniqueProduct]) {
        snapshot = NSDiffableDataSourceSnapshot<SectionKind, UniqueProduct>()
        snapshot.appendSections([.banner])
        snapshot.appendItems(bannerProducts)
        snapshot.appendSections([.list])
        snapshot.appendItems(listProducts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applySnapshotWith(listProducts: [UniqueProduct]) {
        snapshot.appendItems(listProducts, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // TODO: 다른 방법 고민
    private func makeHashable(from products: [Product]) -> [UniqueProduct] {
        var uniqueProducts = [UniqueProduct]()
        products.forEach { product in
            let product = UniqueProduct(product: product)
            uniqueProducts.append(product)
        }
        return uniqueProducts
    }
    
    private func showListRefreshButton(_ newProductDidPost: Observable<Void>) {
        newProductDidPost
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.listRefreshButton.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNewPostedItemsWith(_ newListProducts: Observable<[Product]>) {
        newListProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawBannerAndList(with: products)
                self?.listRefreshButton.isHidden = true
                self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
            })
            .disposed(by: disposeBag)
    }
        
    private func configureNextPageItemsWith(_ nextPageProducts: Observable<[Product]>) {
        nextPageProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawBannerAndList(with: products)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AutoScrollBannerMethods
extension ProductListViewController {
    private func autoScrollBannerTimer(with timeInterval: TimeInterval, productCount: Int) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.scrollBanner(productCount: productCount)
        }
    }
    
    private func scrollBanner(productCount: Int) {
        currentBannerPage += 1
        collectionView.scrollToItem(at: NSIndexPath(item: currentBannerPage, section: 0) as IndexPath,
                                    at: .bottom,
                                    animated: true)
        
        if self.currentBannerPage == productCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToFirstItem()
            }
        }
    }

    private func scrollToFirstItem() {
        collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
        currentBannerPage = 0
    }
}

// MARK: - MenuSegmentedControllViewModelDelegate
extension ProductListViewController: MenuSegmentedControllViewModelDelegate {
    func segmentedControlTapped(_ currentSelectedButton: MenuSegmentedControlViewModel.MenuButton) {
        switch currentSelectedButton {
        case .grid:
            ProductListViewController.isGrid = true
            let changedLayout = createLayout()
            collectionView.collectionViewLayout = changedLayout
            collectionView.reloadData()
        case .table:
            ProductListViewController.isGrid = false
            let changedLayout = createLayout()
            collectionView.collectionViewLayout = changedLayout
            collectionView.reloadData()
        }
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        cellDidScroll.onNext(indexPath)
    }
}
