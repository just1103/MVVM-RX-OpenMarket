import UIKit
import RxSwift

class ProductListViewController: UIViewController {
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
    
    private static var isTable: Bool = true
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var verticalStackView = UIStackView()
    private var bannerDataSource: BannerDiffableDataSource! = nil
    private var listDataSource: ListDiffableDataSource! = nil
    private let viewDidLoadObserver: PublishSubject<Void> = .init()
    private let cellPressedObserver: PublishSubject<IndexPath> = .init()
    private var viewModel: ProductListViewModel!
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: ProductListViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    typealias BannerDiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, UIImage>
    typealias ListDiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, Product>
    typealias BannerCellRegistration = UICollectionView.CellRegistration<BannerCell, UIImage>
    typealias TableListCellRegistration = UICollectionView.CellRegistration<TableListCell, Product>
    typealias GridListCellRegistration = UICollectionView.CellRegistration<GridListCell, Product>

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
        
        configureBannerObserver(output)
    }
    
    private func configureBannerObserver(_ output: ProductListViewModel.Output) {
        output.bannerObserver
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] images in
                self?.configureBannerCellDataSource(from: images)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureBannerCellDataSource(from images: [UIImage]) {
        let bannerCellRegistration = BannerCellRegistration { cell, indexPath, image in
            cell.apply(image: images[indexPath.row])
//            cell.apply(image: images[0])
        }
        
        bannerDataSource = BannerDiffableDataSource(collectionView: collectionView,
                                                    cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: bannerCellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        })
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, UIImage>()
        snapshot.appendSections([.banner])
        snapshot.appendItems(images)
        bannerDataSource.apply(snapshot, animatingDifferences: true)
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false // TODO: 없어도 되는지 테스트

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                print("알 수 없는 Section")
                return nil
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
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
