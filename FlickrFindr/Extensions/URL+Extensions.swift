//
//  URLExtensions.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/26/22.
//

import Foundation

extension URL {
    // Often we run into cases where we are creating a URL with a static string that
    // we know at compile time. We should find and fix these immediately in development
    // instead of passing around an optional object.
    init(staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            fatalError("Failed to initialize a URL with the static string in URL convieniance initializer")
        }
        self = url
    }
}
