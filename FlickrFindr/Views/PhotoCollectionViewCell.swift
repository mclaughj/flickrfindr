//
//  PhotoCollectionViewCell.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/29/22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var photoViewModel: PhotoViewModel? {
        didSet {
            update()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.frame = self.bounds;
        contentView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    private func update() {
        titleLabel.text = photoViewModel?.photo.title
        
        photoViewModel?.fetchImage(for: .thumbnail, with: { [weak self] (id, image) in
            // This check protects against a network race condition.
            //
            // Depending on network speed, the image may load after the cell has already been
            // reused for another image. We need to check against the current photo ID at the
            // time of returning the image to verify we're still good to draw this image.
            //
            // A cleaner approach would probably to build our image fetching pipeline on top
            // of OperationQueue, cleaning up outstanding network requests as soon as we no
            // longer need them. I felt that was out of scope for this example app.
            if self?.photoViewModel?.photo.id == id {
                self?.imageView.image = image
            }
        })
    }
}
