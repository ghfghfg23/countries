//
//  CountryDetailViewModel.swift
//  Countries
//
//  Created by Andrey Ryabov on 27/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxDataSources

class CountryDetailViewModel {
    struct DetailedCountry {
        let country: Country
        let borders: [Country]
    }

    let countriesProvider = MoyaProvider<RestCountries>()
    let countrySubject = PublishSubject<Country>()
    let disposeBag = DisposeBag()
    let state = RxLoadingState<DetailedCountry>()

    func reload() {
        guard let name = countryCode else {
            fatalError("countryCode in the \(CountryDetailViewModel.self) must be set before the 'reload'")
        }
        loadCountry(with: name).subscribe().disposed(by: disposeBag)
    }

    var countryCode: String!
    func loadCountry(with code: String) -> Single<DetailedCountry> {
        return countriesProvider.rx.request(.alpha(codes: [code]))
            .map([Country].self)
            .flatMap({ [countriesProvider] (countries) -> PrimitiveSequence<SingleTrait, DetailedCountry> in
                guard let country = countries.first else {
                    throw CountryNotFound(searchType: .byCode(code))
                }
                guard !country.borders.isEmpty else {
                    return Single.just(DetailedCountry(country: country, borders: []))
                }
                return countriesProvider.rx.request(.alpha(codes: country.borders))
                    .map([Country].self)
                    .map { DetailedCountry(country: country, borders: $0) }
            })
            .do(onSuccess: state.toLoaded, onError: state.toFailure, onSubscribe: state.toLoading)
    }

    var navigationTitleObservable: Observable<String> {
        return countryObservable
            .filter { $0 != nil }
            .map { $0!.country.emoji }
    }

    var countryObservable: Observable<DetailedCountry?> {
        return state.valueObservable
    }

    var sectionsObservable: Observable<[SectionModel<String, TitleValuePair>]> {
        return countryObservable
            .map { $0?.sections ?? [] }
    }
}

typealias TitleValuePair = (title: String, value: String)

fileprivate extension CountryDetailViewModel.DetailedCountry {
    var sections: [SectionModel<String, TitleValuePair>] {
        return [
            SectionModel(model: "Info", items: [
                ("Name", country.formattedName),
                ("Capital", country.capital),
                ("Population", "\(country.population)")
                ]),
            SectionModel(model: "Borders", items: borders.map { ($0.formattedName, "\($0.population)") }),
            SectionModel(model: "Currencies", items: country.currencies.compactMap(formatCurrency))
        ]
    }

    func formatCurrency(_ currency: Currency) -> TitleValuePair? {
        let title = currency.name
        let detail = [currency.code, currency.symbol].compactMap { $0 }.joined(separator: ", ")
        guard detail.count > 0 || title != nil else { return nil }
        return (title ?? "Unknown currency", detail)
    }
}

extension CountryDetailViewModel: RxFailableAsyncContentViewModel { }
