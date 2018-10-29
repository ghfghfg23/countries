//
//  CountryNotFound.swift
//  Countries
//
//  Created by Andrey Ryabov on 29/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation

struct CountryNotFound: Error {
    enum SearchType {
        case byText(String)
        case byCode(String)
    }
    let searchType: SearchType
}

extension CountryNotFound: LocalizedError {
    var errorDescription: String? {
        let formatString = "Country with %@ is not found."
        switch searchType {
        case .byText(let text): return String(format: formatString, "text '\(text)'")
        case .byCode(let code): return String(format: formatString, "alpha code '\(code)'")
        }
    }
}
