import UIKit
import RxSwift
import RxCocoa

class ProductListViewController: UIViewController {
    // MARK: - Nested Types
    enum SectionKind: Int {
        case banner
        case list
        
        var columnCount: Int {
            switch self {
            case .banner:
                return 1
            case .list:
                if ProductListViewController.isTable {
                    return 1
                } else {
                    return 2
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
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let menuSegmentedControl = MenuSegmentedControl() // 위치?
    private var dataSource: DiffableDataSource!
    private var viewModel: ProductListViewModel!
    private let invokedViewDidLoad: PublishSubject<Void> = .init()
//    private let cellDidSelect: PublishSubject<IndexPath> = .init()
    private let disposeBag = DisposeBag()

    // TODO: private 설정
    static var isTable: Bool = true
    private var currentBannerPage: Int = 0
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, UniqueProduct>
    typealias BannerCellRegistration = UICollectionView.CellRegistration<BannerCell, UniqueProduct>
    typealias TableListCellRegistration = UICollectionView.CellRegistration<TableListCell, UniqueProduct>
    typealias GridListCellRegistration = UICollectionView.CellRegistration<GridListCell, UniqueProduct>
    
    // MARK: - Initializer
    convenience init(viewModel: ProductListViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = .white
        navigationItem.titleView = menuSegmentedControl

        navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = false
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationItem.titleView?.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 30).isActive = true
        navigationItem.titleView?.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -30).isActive = true
    }
    
    private func configureCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
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
//                                                           count: 2)
                                                         count: sectionKind.columnCount)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
            
            return section
        }
        return layout
    }
    
    private func bind() {
        let input = ProductListViewModel.Input(invokedViewDidLoad: invokedViewDidLoad.asObservable())
        let output = viewModel.transform(input)

        configureItemsWith(output.bannerProducts, output.listProducts)
    }
    
    private func configureItemsWith(_ bannerProducts: Observable<[Product]>, _ listProducts: Observable<[Product]>) {
        bannerProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                
            })
            .disposed(by: disposeBag)
        
        listProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                guard let self = self else { return }
                let recentBargainProducts = products.filter { product in
                    product.discountedPrice != 0
                }
                let bannerProductsCount = 5
                let bannerProducts = Array(recentBargainProducts[0..<bannerProductsCount])
                
                // FIXME: 동일한 프로덕트가 다른 섹션에 들어가면 에러 발생
                self.configureDataSourceWith(listProducts: self.makeHashable(from: products),
                                             bannerProducts: self.makeHashable(from: bannerProducts))
//                self.autoScrollBannerTimer(with: 2, productCount: bannerProductsCount)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureTableButtonWith(_ tapEvent: Observable<Void>) {
        // TODO: drive를 사용한 방법 알아보기
        tapEvent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
//                self?.makeUnderline()
            })
            .disposed(by: disposeBag)
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
    
    private func configureDataSourceWith(listProducts: [UniqueProduct], bannerProducts: [UniqueProduct]) {
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
                switch ProductListViewController.isTable {
                case true:
                    return collectionView.dequeueConfiguredReusableCell(using: tableListCellRegistration,
                                                                        for: indexPath,
                                                                        item: product)
                case false:
                    return collectionView.dequeueConfiguredReusableCell(using: gridListCellRegistration,
                                                                        for: indexPath,
                                                                        item: product)
                }
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, UniqueProduct>()
        snapshot.appendSections([.banner])
        snapshot.appendItems(bannerProducts)
        snapshot.appendSections([.list])
        snapshot.appendItems(listProducts)
        dataSource.apply(snapshot, animatingDifferences: true)
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
