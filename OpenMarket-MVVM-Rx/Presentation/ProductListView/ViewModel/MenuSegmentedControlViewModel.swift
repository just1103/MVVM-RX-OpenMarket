import Foundation
import RxSwift

protocol MenuSegmentedControllViewModelDelegate: AnyObject {
    func segmentedControlTapped(_ currentSelectedButton: MenuSegmentedControlViewModel.MenuButton)
}

class MenuSegmentedControlViewModel {
    enum MenuButton {
        case table
        case grid
    }
    
    struct Input {
        let gridButtonDidTap: Observable<Void>
        let tableButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let selectedGridButton: Observable<Void>
        let selectedTableButton: Observable<Void>
    }
    
    weak var delegate: MenuSegmentedControllViewModelDelegate?
    private var currentSelectedButton: MenuButton = .grid
    private let disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let selectedGridButton = PublishSubject<Void>()
        let selectedTableButton = PublishSubject<Void>()
        
        configureSelectedGridButtonObserver(inputObservable: input.gridButtonDidTap,
                                            outputObservable: selectedGridButton)
        configureSelectedTableButtonObserver(inputObservable: input.tableButtonDidTap,
                                             outputObservable: selectedTableButton)
        
        let output = Output(selectedGridButton: selectedGridButton.asObservable(),
                            selectedTableButton: selectedTableButton.asObservable())
        
        return output
    }
    
    private func configureSelectedGridButtonObserver(inputObservable: Observable<Void>,
                                                     outputObservable: PublishSubject<Void>) {
        inputObservable
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.currentSelectedButton == .table {
                    self.delegate?.segmentedControlTapped(.grid)
                    outputObservable.onNext(())
                }
                self.currentSelectedButton = .grid
                // TODO: collectionView Layout 수정하고, CellType 바꿔줘야 함 (현재 dequeue 되는 Cell만 바뀜)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSelectedTableButtonObserver(inputObservable: Observable<Void>,
                                                      outputObservable: PublishSubject<Void>) {
        inputObservable
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.currentSelectedButton == .grid {
                    self.delegate?.segmentedControlTapped(.table)
                    outputObservable.onNext(())
                }
                self.currentSelectedButton = .table
            })
            .disposed(by: disposeBag)
    }
}
