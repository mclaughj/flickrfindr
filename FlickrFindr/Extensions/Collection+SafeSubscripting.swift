//
//  Collection+SafeSubscripting.swift
//  Albums
//
//  Created by Joseph McLaughlin on 10/14/19.
//  Copyright © 2019 Zero1 Software LLC. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
