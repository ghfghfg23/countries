//
//  Country.swift
//  Countries
//
//  Created by Andrey Ryabov on 26/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation

struct Country: Decodable {
    let name: String
    let alpha2Code: String
    let population: UInt
    let capital: String
    let borders: [String]
    let currencies: [Currency]

    var formattedName: String {
        return "\(emoji) \(name)"
    }
}

struct Currency: Decodable {
    let code: String?
    let name: String?
    let symbol: String?
}
