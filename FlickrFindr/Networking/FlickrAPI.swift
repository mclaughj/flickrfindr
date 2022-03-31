//
//  FlickrAPI.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/26/22.
//

import Foundation

struct Flickr {
    static let baseURL = URL(staticString: "https://www.flickr.com/")
    static let baseParams = [
        URLQueryItem(name: "api_key", value: "d7556d0c326463212f6f104e4646fafe"),
        URLQueryItem(name: "format", value: "json"),
        URLQueryItem(name: "nojsoncallback", value: "1")
    ]
    
    static var api: APIClient = {
        let configuration = URLSessionConfiguration.default
        return NetworkAPIClient(configuration: configuration)
    }()
}

// Currently, all of our Flickr requests are `get` and the same URL, the only things changing are the params,
// so we can encapsulate all of the core functionality inside this builder.
struct FlickrRequestBuilder: RequestBuilder {
    let method: HTTPMethod = .get
    let baseURL: URL = Flickr.baseURL
    let path: String = "services/rest"
    let params: [URLQueryItem]?
    
    init(params: [URLQueryItem]?) {
        var combinedParams = Flickr.baseParams
        if let params = params {
            combinedParams.append(contentsOf: params)
        }
        self.params = combinedParams
    }
}

extension Request {
    static func searchPhotos(for searchTerm: String, completion: @escaping (Result<PhotoSearchResult, APIError>) -> Void) -> Request {
        let params = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "text", value: searchTerm),
            URLQueryItem(name: "per_page", value: "25")
        ]
        let builder = FlickrRequestBuilder(params: params)
        
        return Request(builder: builder) { result in
            result.decoding(PhotoSearchResult.self, completion: completion)
        }
    }
    
    static func getPhotoDetails(forID photoID: String, andSecret secret: String, completion: @escaping (Result<PhotoDetailResult, APIError>) -> Void) -> Request {
        let params = [
            URLQueryItem(name: "method", value: "flickr.photos.getInfo"),
            URLQueryItem(name: "photo_id", value: photoID),
            URLQueryItem(name: "secret", value: secret)
        ]
        let builder = FlickrRequestBuilder(params: params)
        
        return Request(builder: builder) { result in
            result.decoding(PhotoDetailResult.self, completion: completion)
        }
    }
}
