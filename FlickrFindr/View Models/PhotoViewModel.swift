//
//  PhotoCellViewModel.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/30/22.
//

import Foundation
import UIKit

struct PhotoViewModel {
    
    var photo: Photo
    
    /// Fetch the image for the photo
    /// - Completion block returns:
    ///     - `String`: The ID of the photo that was fetched
    ///     - `UIImage?`: An optional image if the network request was successful
    ///
    /// Currently this doesn't cache images, I felt that was out of scope for this application.
    func fetchImage(for size: PhotoSize, with completion: @escaping (String, UIImage?) -> Void) {
        
        guard let photoURL = URL(string: photo.urlString(for: size)) else {
            completion(photo.id, nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = URLSession(configuration: .default).dataTask(with: photoURL) { data, _, error in
                var returnImage: UIImage?
                defer {
                    DispatchQueue.main.async {
                        completion(photo.id, returnImage)
                    }
                }
                
                guard error == nil else {
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    returnImage = image
                }
            }
            
            task.resume()
        }
    }
    
}
