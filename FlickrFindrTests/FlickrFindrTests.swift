//
//  FlickrFindrTests.swift
//  FlickrFindrTests
//
//  Created by Joseph McLaughlin on 3/25/22.
//

import XCTest
@testable import FlickrFindr

class FlickrFindrModelTests: XCTestCase {
    
    var searchData: Data?
    var detailData: Data?

    override func setUpWithError() throws {
        
        if let url = Bundle(for: type(of: self)).url(forResource: "search-response", withExtension: "json") {
            do {
                searchData = try Data(contentsOf: url)
            } catch {
                XCTFail(error.localizedDescription)
            }
        } else {
            XCTFail("Failed to open search-response.json file")
        }
        
        if let url = Bundle(for: type(of: self)).url(forResource: "photo-detail", withExtension: "json") {
            do {
                detailData = try Data(contentsOf: url)
            } catch {
                XCTFail(error.localizedDescription)
            }
        } else {
            XCTFail("Failed to open photo-detail.json file")
        }

    }
    
    func testImageURLGeneration() throws {
        let testPhoto = SearchPhoto(id: "1", secret: "2", server: "3", title: "")
        
        XCTAssertEqual(testPhoto.urlString(for: .thumbnail), "https://live.staticflickr.com/3/1_2_q.jpg")
        XCTAssertEqual(testPhoto.urlString(for: .small), "https://live.staticflickr.com/3/1_2_w.jpg")
        XCTAssertEqual(testPhoto.urlString(for: .medium), "https://live.staticflickr.com/3/1_2_c.jpg")
        XCTAssertEqual(testPhoto.urlString(for: .large), "https://live.staticflickr.com/3/1_2_b.jpg")
    }

    func testDecodingSearchResults() throws {
        do {
            guard let data = searchData else {
                XCTFail("Failed to unwrap json test data")
                return
            }
            
            let searchResults = try JSONDecoder().decode(PhotoSearchResult.self, from: data)
            
            let photos = searchResults.photos
            
            XCTAssertEqual(photos.count, 25)
            if let firstPhoto = photos.first {
                XCTAssertEqual(firstPhoto.id, "51959073681")
                XCTAssertEqual(firstPhoto.secret, "3911657bcb")
                XCTAssertEqual(firstPhoto.server, "65535")
                XCTAssertEqual(firstPhoto.title, "Creator International Custom Baseball Jersey Button Down Shirts Personalize Stitched Name, Number or Logo for Men Women Youth")
                
                XCTAssertEqual(firstPhoto.urlString(for: .large), "https://live.staticflickr.com/65535/51959073681_3911657bcb_b.jpg")
            } else {
                XCTFail("No first photo in search results")
            }
        } catch DecodingError.keyNotFound(_, let context) {
            XCTFail(context.debugDescription)
        } catch DecodingError.typeMismatch(_, let context) {
            XCTFail(context.debugDescription)
        } catch DecodingError.valueNotFound(_, let context) {
            XCTFail(context.debugDescription)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodingPhotoDetail() throws {
        do {
            guard let data = detailData else {
                XCTFail("Failed to unwrap json test data")
                return
            }
            
            let detailResult = try JSONDecoder().decode(PhotoDetailResult.self, from: data)
            
            let photo = detailResult.photo
            
            XCTAssertEqual(photo.id, "51957499633")
            XCTAssertEqual(photo.secret, "6cbdfb0d53")
            XCTAssertEqual(photo.server, "65535")
            XCTAssertEqual(photo.title, "Boston Red Sox vs. Toronto Blue Jays")
            
            XCTAssertEqual(photo.urlString(for: .large), "https://live.staticflickr.com/65535/51957499633_6cbdfb0d53_b.jpg")
            
        } catch DecodingError.keyNotFound(_, let context) {
            XCTFail(context.debugDescription)
        } catch DecodingError.typeMismatch(_, let context) {
            XCTFail(context.debugDescription)
        } catch DecodingError.valueNotFound(_, let context) {
            XCTFail(context.debugDescription)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // We can easily take these live tests out or move them to a different test target to act as a "canary" test of the Flickr API
    // The network stack is designed to allow mocking, so we should rely on a mocked response to test most aspects of the API code
    func testLiveFlickrSearchAPI() {
        let expectation = XCTestExpectation(description: "API call should return results")
        
        Flickr.api.send(request: .searchPhotos(for: "red sox", completion: { result in
            switch result {
            case .success(let photoResult):
                XCTAssertEqual(photoResult.photos.count, 25)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error from API: \(error.localizedDescription)")
            }
        }))
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testLiveFlickrPhotoDetailAPI() {
        let expectation = XCTestExpectation(description: "API call should return results")
        
        Flickr.api.send(request: .getPhotoDetails(forID: "51957499633", andSecret: "6cbdfb0d53", completion: { result in
            switch result {
            case .success(let photoResult):
                XCTAssertEqual(photoResult.photo.id, "51957499633")
            case .failure(let error):
                XCTFail("Error from API: \(error.localizedDescription)")
            }
            
            expectation.fulfill()
        }))
        
        wait(for: [expectation], timeout: 5)
    }

}
