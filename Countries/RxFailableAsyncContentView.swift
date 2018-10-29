//
//  RxFailableAsyncContentView.swift
//  Countries
//
//  Created by Andrey Ryabov on 28/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol RxFailableAsyncContentView {
    associatedtype ViewModel: RxFailableAsyncContentViewModel
    var viewModel: ViewModel { get }
    var contentView: UIView { get }
    var bindableErrorLabel: UILabel { get }
    var bindableActivityIndicator: UIActivityIndicatorView { get }
    var bindableReloadButton: UIButton { get }
    var disposeBag: DisposeBag { get }
}

extension RxFailableAsyncContentView {
    func bindAsyncContentView() {
        viewModel.isErrorMessageHiddenObservable.bind(to: bindableErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.isErrorMessageHiddenObservable.bind(to: bindableReloadButton.rx.isHidden).disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.hasContentObservable,
            viewModel.isErrorMessageHiddenObservable
        ).map { !$0 || !$1  }.bind(to: contentView.rx.isHidden).disposed(by: disposeBag)

        viewModel.errorTextObservable.bind(to: bindableErrorLabel.rx.text).disposed(by: disposeBag)

        viewModel.isLoadingObservable.bind(to: bindableActivityIndicator.rx.isAnimating).disposed(by: disposeBag)
        viewModel.isLoadingObservable.map { !$0 }.bind(to: bindableReloadButton.rx.isEnabled).disposed(by: disposeBag)

        bindableReloadButton.rx.tap.bind(onNext: viewModel.reload).disposed(by: disposeBag)
    }
}

protocol RxFailableAsyncContentViewModel {
    associatedtype ContentType
    func reload()
    var state: RxLoadingState<ContentType> { get }
    var hasContentObservable: Observable<Bool> { get }
    var isErrorMessageHiddenObservable: Observable<Bool> { get }
    var isLoadingObservable: Observable<Bool> { get }
    var errorTextObservable: Observable<String?> { get }
}

extension RxFailableAsyncContentViewModel {
    var hasContentObservable: Observable<Bool> {
        return state.valueObservable.map { $0 != nil }
    }
    var isErrorMessageHiddenObservable: Observable<Bool> {
        return state.errorObservable.map { $0 == nil }
    }

    var isLoadingObservable: Observable<Bool> {
        return state.isLoadingObservable
    }
    var errorTextObservable: Observable<String?> {
        return state.errorObservable
            .map { error in
                guard let desc = error?.localizedDescription else { return nil }
                return "Error occured: \(desc)"
        }
    }
}
