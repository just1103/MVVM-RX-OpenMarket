import UIKit
import RxSwift

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
    
    enum MenuButton {
        case table
        case grid
        case bargain
    }
        
    // MARK: - Properties
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var verticalStackView = UIStackView()
    private var bannerDataSource: BannerDiffableDataSource!
    private var tableListDataSource: ListDiffableDataSource!
    private var gridListDataSource: ListDiffableDataSource!
    private var viewModel: ProductListViewModel!
    private let viewDidLoadObserver: PublishSubject<Void> = .init()
    private let cellPressedObserver: PublishSubject<IndexPath> = .init()
    private let disposeBag = DisposeBag()

    private static var isTable: Bool = true
    private var currentBannerPage: Int = 0
    
    typealias BannerDiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, UIImage>
    typealias ListDiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, Product>
    typealias BannerCellRegistration = UICollectionView.CellRegistration<BannerCell, UIImage>
    typealias TableListCellRegistration = UICollectionView.CellRegistration<TableListCell, Product>
    typealias GridListCellRegistration = UICollectionView.CellRegistration<GridListCell, Product>
    
    // MARK: - Initializer
    convenience init(viewModel: ProductListViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureHierarchy()
        viewDidLoadObserver.onNext(())
    }
    
    private func bind() {
        let input = ProductListViewModel.Input(viewDidLoadObserver: viewDidLoadObserver.asObservable(),
                                               cellPressedObserver: cellPressedObserver.asObservable())
        let output = viewModel.transform(input)

        configureBannerObserver(output.bannerObserver)
        configureListObserver(output.listObserver)
//        drawwww(observable: output.productsObserver)
    }
    
    private func configureBannerObserver(_ observable: Observable<[UIImage]>) {
        observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] images in
                self?.configureBannerCellDataSource(from: images)
                
                self?.autoScrollBannerTimer(with: 2, imageCount: images.count)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureBannerCellDataSource(from images: [UIImage]) {
        let bannerCellRegistration = BannerCellRegistration { cell, indexPath, image in
            cell.apply(image: images[indexPath.row])
        }
        
        bannerDataSource = BannerDiffableDataSource(collectionView: collectionView,
                                                    cellProvider: { collectionView, indexPath, image in
            return collectionView.dequeueConfiguredReusableCell(using: bannerCellRegistration,
                                                                for: indexPath,
                                                                item: image)
        })
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, UIImage>()
        snapshot.appendSections([.banner])
        snapshot.appendItems(images)
        bannerDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureListObserver(_ observable: Observable<[Product]>) {
        observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in  // FIXME: products 없어서 dispose로 넘어감
                self?.configureListCellDataSource(from: products)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureListCellDataSource(from products: [Product]) {
        let tableListCellRegistration = TableListCellRegistration { cell, indexPath, product in // TODO: product 왜있는거지?
            cell.apply(data: products[indexPath.row])
        }
        
        let gridListCellRegistration = GridListCellRegistration { cell, indexPath, product in
            cell.apply(data: products[indexPath.row])
        }

        switch ProductListViewController.isTable {
        case true:
            tableListDataSource = ListDiffableDataSource(collectionView: collectionView,
                                                         cellProvider: { collectionView, indexPath, product in
                return collectionView.dequeueConfiguredReusableCell(using: tableListCellRegistration,
                                                                    for: indexPath,
                                                                    item: product)
            })
        case false:
            gridListDataSource = ListDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { collectionView, indexPath, product in
                return collectionView.dequeueConfiguredReusableCell(using: gridListCellRegistration,
                                                                    for: indexPath,
                                                                    item: product)
            })
        }

        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Product>()
        snapshot.appendSections([.list])
        snapshot.appendItems(products)  // fetchProducts 다되면 또는 products 변경되면 -> Rx로 연결해서 다시 그려라
        tableListDataSource.apply(snapshot, animatingDifferences: true) // TODO: false로 변경
        gridListDataSource.apply(snapshot, animatingDifferences: true)
    }
    
//    private func drawwww(observable: Observable<[Product]>) {
//        observable
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] products in
//            let tableListCellRegistration = TableListCellRegistration { cell, indexPath, product in // TODO: product 왜있는거지?
//                cell.apply(data: products[indexPath.row])
//            }
//
//            let gridListCellRegistration = GridListCellRegistration { cell, indexPath, product in
//                cell.apply(data: products[indexPath.row])
//            }
//
//            switch ProductListViewController.isTable {
//            case true:
//                guard let self = self else { return }
//                self.tableListDataSource = ListDiffableDataSource(collectionView: self.collectionView,
//                                                             cellProvider: { collectionView, indexPath, product in
//                    return collectionView.dequeueConfiguredReusableCell(using: tableListCellRegistration,
//                                                                        for: indexPath,
//                                                                        item: product)
//                })
//            case false:
//                guard let self = self else { return }
//                self.gridListDataSource = ListDiffableDataSource(collectionView: self.collectionView,
//                                                            cellProvider: { collectionView, indexPath, product in
//                    return collectionView.dequeueConfiguredReusableCell(using: gridListCellRegistration,
//                                                                        for: indexPath,
//                                                                        item: product)
//                })
//            }
//
//            var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Product>()
//            snapshot.appendSections([.list])
//            snapshot.appendItems(products)  // TODO: fetchProducts 완료되거나 Products 변경되면 다시 그리도록 Rx 적용
//            self?.tableListDataSource.apply(snapshot, animatingDifferences: false)
////            self?.gridListDataSource.apply(snapshot, animatingDifferences: false)
//        })
//    }
    
    private func autoScrollBannerTimer(with timeInterval: TimeInterval, imageCount: Int) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.scrollBanner(imageCount: imageCount)
        }
    }
    
    private func scrollBanner(imageCount: Int) {
        currentBannerPage += 1
        collectionView.scrollToItem(at: NSIndexPath(item: currentBannerPage, section: 0) as IndexPath,
                                    at: .bottom,
                                    animated: true)
        
        if self.currentBannerPage == imageCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToFirstItem()
            }
        }
    }

    private func scrollToFirstItem() {
        collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
        currentBannerPage = 0
    }
    
    private func configureHierarchy() {
        configureStackView()
        configureCollectionView()
    }
    
    private func configureStackView() {
        view.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fill
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureCollectionView() {
        verticalStackView.addArrangedSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                print("알 수 없는 Section")
                return nil
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.2))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: sectionKind.columnCount)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
            
            return section
        }
        return layout
    }
}
