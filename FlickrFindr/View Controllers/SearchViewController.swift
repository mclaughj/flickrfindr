//
//  SearchViewController.swift
//  FlickrFindr
//
//  Created by Joseph McLaughlin on 3/25/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct Constants {
        static let kSearchPhotoCellIdentifier = "searchPhotoCell"
        static let kShowDetailSegueIdentifier = "showPhotoDetail"
        
        static let kCellSpacing: CGFloat = 8
        static let kItemsPerRow: CGFloat = 2
    }
    
    private var photos = [SearchPhoto]()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    lazy private var searchBarView: UIView = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBarView
    }

    func updateWithPhotos(_ photos: [SearchPhoto]) {
        self.photos = photos
        collectionView.reloadData()
        collectionView.contentOffset = .zero
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.kSearchPhotoCellIdentifier, for: indexPath)
        
        guard let photo = photos[safe: indexPath.row], let photoCell = cell as? PhotoCollectionViewCell else {
            return cell
        }
        
        let photoViewModel = PhotoViewModel(photo: photo)
        photoCell.photoViewModel = photoViewModel
        
        return photoCell
    }

}

extension SearchViewController: UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
           identifier == Constants.kShowDetailSegueIdentifier,
           let tappedCell = sender as? PhotoCollectionViewCell,
           let detailViewController = segue.destination as? DetailViewController {
            
            detailViewController.photoViewModel = tappedCell.photoViewModel
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellSideLength = (collectionView.frame.size.width - ((Constants.kItemsPerRow + 1) * Constants.kCellSpacing)) / Constants.kItemsPerRow
        return CGSize(width: cellSideLength, height: cellSideLength)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            // We could alert the user here that they need to enter search text
            return
        }
        
        Flickr.api.send(request: .searchPhotos(for: searchText, completion: { result in
            switch result {
            case .success(let searchResult):
                self.updateWithPhotos(searchResult.photos)
            case .failure(let error):
                // We should display an error to the user in a production app
                print(error)
            }
        }))
    }
    
}
