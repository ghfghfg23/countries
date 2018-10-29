//
//  LoadingState.swift
//  Countries
//
//  Created by Andrey Ryabov on 27/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation
import RxSwift

enum LoadingState<T> {
    case notLoaded
    indirect case loading(previous: LoadingState<T>)
    case loaded(value: T)
    case failure(error: Error)

    var value: T? {
        switch self {
        case .loaded(let value): return value
        case .loading(.loaded(let value)): return value
        default: return nil
        }
    }
    var error: Error? {
        switch self {
        case .failure(let error): return error
        case .loading(.failure(let error)): return error
        default: return nil
        }
    }
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
}

class RxLoadingState<T> {
    var subject: BehaviorSubject<LoadingState<T>> = BehaviorSubject<LoadingState<T>>(value: .notLoaded)

    var valueObservable: Observable<T?> {
        return subject.asObservable().map { $0.value }
    }
    var errorObservable: Observable<Error?> {
        return subject.asObservable().map { $0.error }
    }
    var isLoadingObservable: Observable<Bool> {
        return subject.asObservable().map { $0.isLoading }
    }

    func toLoading() {
        guard let currentState = try? subject.value() else {
            subject.onNext(.notLoaded)
            return
        }
        subject.onNext(.loading(previous: currentState))
    }
    func toFailure(_ error: Error) {
        subject.onNext(.failure(error: error))
    }
    func toLoaded(_ value: T) {
        subject.onNext(.loaded(value: value))
    }
}
