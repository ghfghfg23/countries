//
//  EmojiConvertible.swift
//  Countries
//
//  Created by Andrey Ryabov on 27/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import Foundation

private let regionalIndicatorSymbolOffset: UInt32 = 0x1F1A5
protocol EmojiConvertable {
    var emoji: String { get }
}

extension Country: EmojiConvertable {
    var emoji: String {
        return String(
            String.UnicodeScalarView(
                alpha2Code.uppercased()
                    .unicodeScalars.map { UnicodeScalar($0.value + regionalIndicatorSymbolOffset)! }
            )
        )
    }
}
