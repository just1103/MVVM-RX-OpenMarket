import UIKit

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
    private var collectionView = ProductCollectionView()
    private var verticalStackView = UIStackView()
    private var dataSource: UICollectionViewDiffableDataSource<SectionKind, Product>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
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
            verticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureCollectionView() {
        verticalStackView.addArrangedSubview(collectionView)
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                print("알 수 없는 Section")
                return nil
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 10.0, bottom: 0.0, trailing: 10.0)
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
