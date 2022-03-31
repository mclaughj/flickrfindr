//
//  Networking.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/26/22.
//

import Foundation

// We only need `get` for our app right now, but it's easy enough to define all of them
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// This is a fairly simple network stack that I like, but there are a lot of ways to do this
protocol APIClient {
    init(configuration: URLSessionConfiguration)
    
    func send(request: Request)
}

struct NetworkAPIClient: APIClient {
    private let session: URLSession
    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    func send(request: Request) {
        guard let urlRequest = request.builder.urlRequest else {
            // In a real app, we should handle this error instead of swallowing it
            return
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            let result: Request.RequestResult
            if let error = error {
                result = .failure(.networkError(error))
            } else if let apiError = APIError.error(from: response) {
                result = .failure(apiError)
            } else {
                result = .success(data ?? Data())
            }
            
            DispatchQueue.main.async {
                request.completion(result)
            }
        }
        
        task.resume()
    }
}

// Some basic error handling
enum APIError: Error {
    case unknownURLResponse
    case networkError(Error)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case unhandledError
    
    static func error(from response: URLResponse?) -> APIError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .unknownURLResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return .requestError(httpResponse.statusCode)
        case 500...599:
            return .serverError(httpResponse.statusCode)
        default:
            return .unhandledError
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .unknownURLResponse:
            return "Response from endpoint isn't a URL response"
        case .networkError(let error):
            return "Network connection issue, please check your network connection (\(error))"
        case .requestError(let code):
            return "Request error (response code: \(code))"
        case .serverError(let code):
            return "Server error (response code: \(code))"
        case .decodingError(let decodingError):
            return "Decoding error (\(decodingError.localizedDescription))"
        case .unhandledError:
            return "Unhandled error"
        }
    }
}

protocol RequestBuilder {
    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var params: [URLQueryItem]? { get }
    
    var urlRequest: URLRequest? { get }
}

extension RequestBuilder {
    var urlRequest: URLRequest? {
        
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            // I'm using a fatal error here because this is an exceptional case that should be
            // caught during development. If the base URL is malformed, all network requests
            // will fail, rendering our app useless.
            fatalError("Failed to initialize a URLComponents object with base URL")
        }
        
        urlComponents.queryItems = params
        
        guard let url = urlComponents.url else {
            // We use an assertion failure here because sometimes the URL params will be determined
            // at runtime (like with user input). We're going to need to handle this error and bubble
            // it up to the user.
            assertionFailure("Failed to get valid URL from URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
}

struct Request {
    typealias RequestResult = Result<Data, APIError>
    typealias RequestCompletion = (RequestResult) -> Void
    
    let builder: RequestBuilder
    let completion: RequestCompletion
   
    init(builder: RequestBuilder, completion: @escaping RequestCompletion) {
      self.builder = builder
      self.completion = completion
    }
}

extension Result where Success == Data, Failure == APIError {
    func decoding<M: Decodable>(_ model: M.Type, completion: @escaping (Result<M, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.flatMap { data -> Result<M, APIError> in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(M.self, from: data)
                    
                    return .success(model)
                } catch let e as DecodingError {
                    return .failure(.decodingError(e))
                } catch {
                    return .failure(.unhandledError)
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
