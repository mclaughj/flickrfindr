//
//  DetailViewController.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/31/22.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var photoViewModel: PhotoViewModel? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func update() {
        
        activityIndicator.startAnimating()
        
        photoViewModel?.fetchImage(for: .large, with: { [weak self] (_, image) in
            self?.imageView.image = image
            self?.activityIndicator.stopAnimating()
        })
    }

}
