import Foundation
import RxSwift

protocol UnderlinedMenuBarViewModelDelegate: AnyObject {
    func underlinedMenuBarTapped(_ currentSelectedButton: UnderlinedMenuBarViewModel.MenuButton)
}

final class UnderlinedMenuBarViewModel {
    // MARK: - Nested Types
    enum MenuButton {
        case table, grid
    }
    
    struct Input {
        let gridButtonDidTap: Observable<Void>
        let tableButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let selectedGridButton: Observable<Void>
        let selectedTableButton: Observable<Void>
    }
    
    // MARK: - Properties
    weak var delegate: UnderlinedMenuBarViewModelDelegate?
    private(set) var currentSelectedButton: MenuButton = .grid
    private let disposeBag = DisposeBag()
    
    // MARK: - Methods
    func transform(_ input: Input) -> Output {
        let selectedGridButton = configureSelectedGridButtonObserver(inputObservable: input.gridButtonDidTap)
        let selectedTableButton = configureSelectedTableButtonObserver(inputObservable: input.tableButtonDidTap)
        
        let output = Output(selectedGridButton: selectedGridButton,
                            selectedTableButton: selectedTableButton)
        
        return output
    }
    
    private func configureSelectedGridButtonObserver(inputObservable: Observable<Void>) -> Observable<Void> {
        return inputObservable
            .map { [weak self] _ in
                if self?.currentSelectedButton == .table {
                    self?.delegate?.underlinedMenuBarTapped(.grid)
                }
                self?.currentSelectedButton = .grid
            }
    }
    
    private func configureSelectedTableButtonObserver(inputObservable: Observable<Void>) -> Observable<Void> {
        inputObservable
            .map { [weak self] _ in
                if self?.currentSelectedButton == .grid {
                    self?.delegate?.underlinedMenuBarTapped(.table)
                }
                self?.currentSelectedButton = .table
            }
    }
}
