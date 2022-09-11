import UIKit
import RxSwift
import RxCocoa

protocol ActivityIndicatorSwitchable: AnyObject {
    func showActivityIndicator()
}

final class ProductListViewController: UIViewController, ActivityIndicatorSwitchable {
    // MARK: - Nested Types
    private enum SupplementaryKind {
        static let header = "header-element-kind"
        static let footer = "footer-element-kind"
    }
    
    private enum SectionKind: Int {
        case banner, list
        
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
        stackView.style(axis: .vertical, alignment: .fill, distribution: .fill)
        return stackView
    }()
    private let listRefreshButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.backgroundColor = UIColor.lightGreenColor
        button.setTitle(Content.listRefreshButtonTitle, for: .normal)
        button.titleLabel?.font = Design.listRefreshButtonTitleFont
        button.isHidden = true
        return button
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private static var isGrid: Bool = true
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var underlinedMenuBar: UnderlinedMenuBar!
    private var dataSource: DiffableDataSource!
    private var snapshot: NSDiffableDataSourceSnapshot<SectionKind, UniqueProduct>!
    private var viewModel: ProductListViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let cellDidScroll = PublishSubject<IndexPath>()
    private let currentBannerPage = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<SectionKind, UniqueProduct>
    private typealias BannerCellRegistration = UICollectionView.CellRegistration<BannerCell, UniqueProduct>
    private typealias TableListCellRegistration = UICollectionView.CellRegistration<TableListCell, UniqueProduct>
    private typealias GridListCellRegistration = UICollectionView.CellRegistration<GridListCell, UniqueProduct>
    private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<HeaderView>
    private typealias FooterRegistration = UICollectionView.SupplementaryRegistration<FooterView>
    
    // MARK: - Initializers
    convenience init(viewModel: ProductListViewModel, underlinedMenuBar: UnderlinedMenuBar) {
        self.init()
        self.viewModel = viewModel
        self.underlinedMenuBar = underlinedMenuBar
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIOSVersion()
        configureUI()
        configureCellRegistrationAndDataSource()
        configureSupplementaryViewRegistrationAndDataSource()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.backgroundColor,
                                                                   .font: UIFont.preferredFont(forTextStyle: .title1)]
    }
    
    // MARK: - Methods
    private func checkIOSVersion() {
        let versionNumbers = UIDevice.current.systemVersion.components(separatedBy: ".")
        let major = versionNumbers[0]
        let minor = versionNumbers[1]
        let version = major + "." + minor
        
        guard let systemVersion = Double(version) else { return }
        let errorVersion = 15.0..<15.4
        // 해당 버전만 is stuck in its update/layout loop. 에러가 발생하여 Alert로 업데이트 권고
        if  errorVersion ~= systemVersion {
            showErrorVersionAlert()
        }
    }
    
    private func showErrorVersionAlert() {
        let okAlertAction = UIAlertAction(title: Content.okAlertActionTitle, style: .default)
        let alert = AlertFactory().createAlert(title: Content.versionErrorTitle,
                                               message: Content.versionErrorMessage,
                                               actions: okAlertAction)
        present(alert, animated: true)
    }
    
    private func configureUI() {
        configureNavigationBar()
        configureStackView()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = UIColor.darkGreenColor
        navigationItem.title = Content.navigationTitle
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.backgroundColor,
                                                                   .font: UIFont.preferredFont(forTextStyle: .title2)]
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    }
    
    private func configureStackView() {
        view.addSubview(underlinedMenuBar)
        view.addSubview(containerStackView)
        view.addSubview(activityIndicator)
        containerStackView.addArrangedSubview(listRefreshButton)
        containerStackView.addArrangedSubview(collectionView)
        
        NSLayoutConstraint.activate([
            underlinedMenuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            underlinedMenuBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: 20),
            underlinedMenuBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                        constant: -20),
            underlinedMenuBar.bottomAnchor.constraint(equalTo: containerStackView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.backgroundColor
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                self?.showUnknownSectionErrorAlert()
                return nil
            }
            let screenWidth = UIScreen.main.bounds.width
            let estimatedHeight = NSCollectionLayoutDimension.estimated(screenWidth)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: sectionKind.columnCount)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
            section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
                let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
                if environment.container.contentSize.height == environment.container.contentSize.width {
                    self?.currentBannerPage.onNext(bannerIndex)
                }
            }
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight),
                elementKind: SupplementaryKind.header,
                alignment: .top
            )
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight),
                elementKind: SupplementaryKind.footer,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
            return section
        }
        return layout
    }
    
    private func showUnknownSectionErrorAlert() {
        let okAlertAction = UIAlertAction(title: Content.okAlertActionTitle, style: .default)
        let alert = AlertFactory().createAlert(title: Content.unknownSectionErrorTitle, actions: okAlertAction)
        present(alert, animated: true)
    }
    
    private func configureCellRegistrationAndDataSource() {
        let bannerCellRegistration = BannerCellRegistration { cell, _, uniqueProduct in
            cell.apply(imageURL: uniqueProduct.product.thumbnail, productID: uniqueProduct.product.id)
        }
        let tableListCellRegistration = TableListCellRegistration { cell, _, uniqueProduct in
            cell.apply(data: uniqueProduct.product)
        }
        let gridListCellRegistration = GridListCellRegistration { cell, _, uniqueProduct in
            cell.apply(data: uniqueProduct.product)
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
    
    private func configureSupplementaryViewRegistrationAndDataSource() {
        let headerRegistration = HeaderRegistration(elementKind: SupplementaryKind.header) { view, _, indexPath in
            view.apply(indexPath)
        }
        let footerRegistration = FooterRegistration(elementKind: SupplementaryKind.footer) { [weak self] view, _, indexPath in
            guard let self = self else { return }
            view.bind(input: self.currentBannerPage.asObservable(),
                      indexPath: indexPath,
                      pageNumber: Content.bannerCount)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] _, kind, index in
            switch kind {
            case SupplementaryKind.header:
                return self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration,
                                                                                   for: index)
            case SupplementaryKind.footer:
                return self?.collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration,
                                                                                   for: index)
            default:
                return UICollectionReusableView()
            }
        }
    }
}

// MARK: - Rx Binding Methods
extension ProductListViewController {
    private func bind() {
        let selectedCellObservable = collectionView.rx.itemSelected.asObservable()
            .map { [weak self] indexPath -> Int in
                let cell = self?.collectionView.cellForItem(at: indexPath)
                var productID = 0
                switch cell {
                case let bannerCell as BannerCell:
                    productID = bannerCell.productID
                case let tableListCell as TableListCell:
                    productID = tableListCell.productID
                case let gridCell as GridListCell:
                    productID = gridCell.productID
                default:
                    break
                }
                return productID
            }
        
        let input = ProductListViewModel.Input(invokedViewDidLoad: invokedViewDidLoad.asObservable(),
                                               rightBarButtonDidTap: navigationItem.rightBarButtonItem?.rx.tap.asObservable(),
                                               listRefreshButtonDidTap: listRefreshButton.rx.tap.asObservable(),
                                               cellDidScroll: cellDidScroll.asObservable(),
                                               cellDidSelect: selectedCellObservable)
        
        let output = viewModel.transform(input)
        
        configureItemsWith(output.products)
        showListRefreshButton(output.newProductDidPost)
        configureNewPostedItemsWith(output.newPostedProducts)
        configureNextPageItemsWith(output.nextPageProducts)
        
        // FIXME: Diffable이라서 이걸 못쓰는듯?
//        currentBannerPage
//            .asDriver(onErrorJustReturn: 0)
//            .drive(collectionView.headerView.pageControl.rx.currentPage)
    }
    
    private func configureItemsWith(_ products: Observable<([UniqueProduct], [UniqueProduct])>) {
        products
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawBannerAndList(with: products)
                self?.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
    }
    
    private func drawBannerAndList(with products: (list: [UniqueProduct], banner: [UniqueProduct])) {
        if snapshot == nil {
            configureInitialSnapshotWith(listProducts: products.list, bannerProducts: products.banner)
        } else {
            applySnapshotWith(listProducts: products.list)
        }
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
    
    private func showListRefreshButton(_ newProductDidPost: Observable<Void>) {
        newProductDidPost
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.listRefreshButton.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNewPostedItemsWith(_ newListProducts: Observable<[UniqueProduct]>) {
        newListProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawNewList(with: products)
                self?.listRefreshButton.isHidden = true
                self?.collectionView.setContentOffset(CGPoint.zero, animated: true)
                self?.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
    }
    
    private func drawNewList(with products: [UniqueProduct]) {
        deleteAndApplySnapshot(listProducts: products)
    }
    
    private func deleteAndApplySnapshot(listProducts: [UniqueProduct]) {
        let previousProducts = snapshot.itemIdentifiers(inSection: .list)
        snapshot.deleteItems(previousProducts)
        snapshot.appendItems(listProducts, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureNextPageItemsWith(_ nextPageProducts: Observable<[UniqueProduct]>) {
        nextPageProducts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] products in
                self?.drawBannerAndList(with: (products, []))
                self?.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UnderlinedMenuBar ViewModelDelegate
extension ProductListViewController: UnderlinedMenuBarViewModelDelegate {
    func underlinedMenuBarTapped(_ currentSelectedButton: UnderlinedMenuBarViewModel.MenuButton) {
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

// MARK: - CollectionView Delegate
extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            cellDidScroll.onNext(indexPath)
        }
    }
}

// MARK: - Activity Indicator
extension ProductListViewController {
    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - NameSpaces
extension ProductListViewController {
    private enum Content {
        static let navigationTitle = "애호마켓"
        static let listRefreshButtonTitle = "업데이트된 상품 목록을 확인하려면 여기를 탭해주세요."
        static let bannerCount = 5
        static let unknownSectionErrorTitle = "알 수 없는 Section입니다"
        static let versionErrorTitle = "기기를 iOS 15.4 이상으로 업데이트 해주세요"
        static let versionErrorMessage = "애플이 잘못했어요"
        static let okAlertActionTitle = "OK"
    }
    
    private enum Design {
        static let listRefreshButtonTitleFont: UIFont = .preferredFont(forTextStyle: .body)
    }
}
