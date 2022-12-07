//
//  SearchingViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 23.11.2022.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewControllerDidTapped(_ movie: TitleMovie)
}

class SearchingViewController: UIViewController {
    
    var titleMovies = [TitleMovie]()
    
    weak var delegate: SearchViewControllerDelegate?
    
    public let searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 200)
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(searchResultsCollectionView)
        searchResultsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            searchResultsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchResultsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchResultsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension SearchingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: titleMovies[indexPath.row].poster_path ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.searchViewControllerDidTapped(titleMovies[indexPath.row])
    }
}
