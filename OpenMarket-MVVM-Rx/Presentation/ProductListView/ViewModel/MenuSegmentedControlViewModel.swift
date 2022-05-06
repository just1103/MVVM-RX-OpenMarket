import Foundation
import RxSwift

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
                if self?.currentSelectedButton == .table {
                    outputObservable.onNext(())
                }
                self?.currentSelectedButton = .grid
                ProductListViewController.isTable = false
                // TODO: collectionView Layout 수정하고, CellType 바꿔줘야 함 (현재 dequeue 되는 Cell만 바뀜)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSelectedTableButtonObserver(inputObservable: Observable<Void>,
                                                      outputObservable: PublishSubject<Void>) {
        inputObservable
            .subscribe(onNext: { [weak self] _ in
                if self?.currentSelectedButton == .grid {
                    outputObservable.onNext(())
                }
                self?.currentSelectedButton = .table
                ProductListViewController.isTable = true
            })
            .disposed(by: disposeBag)
    }
}
