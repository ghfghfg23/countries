//
//  RestCountries.swift
//  Countries
//
//  Created by Andrey Ryabov on 27/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation
import Moya

enum RestCountries: TargetType {
    case all
    case name(countryName: String)
    case alpha(codes: [String])
}

extension RestCountries {
    var baseURL: URL {
        return URL(string: "https://restcountries.eu/")!
    }

    var path: String {
        switch self {
        case .all: return "rest/v2/all"
        case .name(let name): return "rest/v2/name/\(name.lowercased())"
        case .alpha: return "rest/v2/alpha"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        let filterFields = ["name", "alpha2Code", "population", "capital", "borders", "currencies"]
            .joined(separator: ";")
        switch self {
        case .alpha(let codes):
            return .requestParameters(
                parameters: ["codes": codes.map { $0.lowercased() }.joined(separator: ";"),
                             "fields": filterFields],
                encoding: URLEncoding.default)
        default: return .requestParameters(parameters: ["fields": filterFields], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

}
