//
//  SearchViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 19.11.2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    var titleMovies = [TitleMovie]()
    
    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchingViewController())
        controller.searchBar.placeholder = "Search Movies or TVs..."
        controller.searchBar.searchBarStyle = .minimal
        
        return controller
    }()
    
    let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        view.addSubview(searchTableView)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        applyConstraints()
        
        fetchDiscoverMovies()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscovered { results in
            switch results {
            case .success(let titleMovies):
                self.titleMovies = titleMovies
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        let titleMovies = titleMovies[indexPath.row]
        let model = TitleViewModel(titleName: titleMovies.original_title ?? titleMovies.original_name ?? "Unknow", posterURL: titleMovies.poster_path ?? "")
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MoviePreViewController()
        vc.movie = titleMovies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating, SearchViewControllerDelegate {
    
    func searchViewControllerDidTapped(_ movie: TitleMovie) {
        let vc = MoviePreViewController()
        vc.movie = movie
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultSearch = searchController.searchResultsController as? SearchingViewController else { return }
        resultSearch.titleMovies.removeAll()
        let searchBar = searchController.searchBar
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count >= 2 else { return }
        
        resultSearch.delegate = self
        
        APICaller.shared.getSearched(with: query) { result in
            switch result {
            case .success(let titleMovies):
                resultSearch.titleMovies = titleMovies
                DispatchQueue.main.async {
                    resultSearch.searchResultsCollectionView.reloadData()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
