//
//  CountryListViewModel.swift
//  Countries
//
//  Created by Andrey Ryabov on 27/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class CountryListViewModel {
    let countriesProvider = MoyaProvider<RestCountries>()
    let disposeBag = DisposeBag()
    func reload() {
        load(with: searchText.value)
    }

    func load(with searchString: String?) {
        loadCountries(with: searchString)
            .catchErrorJustReturn([])
            .subscribe().disposed(by: disposeBag)
    }

    func loadCountries(with searchString: String? = nil) -> Single<[Country]> {
        let request: RestCountries = searchString.flatMap { str in
            guard !str.isEmpty else { return nil }
            return .name(countryName: str)
        } ?? .all
        return countriesProvider.rx.request(request)
            .flatMap({ (response) -> PrimitiveSequence<SingleTrait, Response> in
                guard response.statusCode != 404 else { throw CountryNotFound(searchType: .byText(searchString!)) }
                return Single.just(response)
            })
            .map([Country].self)
            .catchError({ (error) -> PrimitiveSequence<SingleTrait, [Country]> in
                guard searchString != nil else { throw error }
                return Single.just([])
            })
            .do(onSuccess: state.toLoaded, onError: state.toFailure, onSubscribed: state.toLoading)
    }

    lazy var searchText: Variable<String?> = {
        let variable: Variable<String?> = Variable<String?>(nil)
        variable.asObservable()
            .flatMap({ text -> Observable<String?> in
                if text == nil || text!.isEmpty {
                    return Observable.just(nil)
                }
                return Observable.just(text)
            })
            .distinctUntilChanged()
            .bind(onNext: load)
            .disposed(by: disposeBag)
        return variable
    }()

    let state = RxLoadingState<[Country]>()

    var countryListObservable: Observable<[Country]> {
        return state.valueObservable.filter({ $0 != nil }).map { $0! }
    }
}

extension CountryListViewModel: RxFailableAsyncContentViewModel {
    var hasContentObservable: Observable<Bool> {
        return Observable.combineLatest(
            state.valueObservable.map { $0 != nil },
            searchText.asObservable().map { $0 != nil && !$0!.isEmpty }
        ).map { $0 || $1 }
    }
}
