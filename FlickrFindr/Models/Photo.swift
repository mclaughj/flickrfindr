//
//  Photo.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/25/22.
//

import Foundation

struct PhotoSearchResult: Decodable {
    let photos: [SearchPhoto]
    
    enum RootCodingKeys: String, CodingKey {
        case photosRoot = "photos"
    }
    
    enum PhotosCodingKeys: String, CodingKey {
        case photos = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let photosContainer = try rootContainer.nestedContainer(keyedBy: PhotosCodingKeys.self, forKey: .photosRoot)
        photos = try photosContainer.decode([SearchPhoto].self, forKey: .photos)
    }
}

struct PhotoDetailResult: Decodable {
    let photo: DetailsPhoto
}

enum PhotoSize {
    case thumbnail
    case small
    case medium
    case large
    
    var apiValue: String {
        switch self {
        case .thumbnail:
            return "q"
        case .small:
            return "w"
        case .medium:
            return "c"
        case .large:
            return "b"
        }
    }
}

protocol Photo: Decodable {
    var id: String { get }
    var secret: String { get }
    var server: String { get }
    var title: String { get }
    
    func urlString(for size: PhotoSize) -> String
}

extension Photo {
    func urlString(for size: PhotoSize) -> String {
        // We don't do any sort of sanitization of these values since they come directly from the API -
        // If they don't work, there's nothing much we can do clientside about that.
        return "https://live.staticflickr.com/\(self.server)/\(self.id)_\(self.secret)_\(size.apiValue).jpg"
    }
}

struct SearchPhoto: Photo {
    let id: String
    let secret: String
    let server: String
    let title: String
}

struct DetailsPhoto: Photo {
    let id: String
    let secret: String
    let server: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id, secret, server, title
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        secret = try container.decode(String.self, forKey: .secret)
        server = try container.decode(String.self, forKey: .server)
        title = try container.decode(ContentWrapper.self, forKey: .title).content
    }
}

struct ContentWrapper: Decodable {
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case content = "_content"
    }
}

