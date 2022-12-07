//
//  DownloadsViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 19.11.2022.
//

import UIKit

class DownloadsViewController: UIViewController {

    var movieItem = [MovieItem]()
        
    let downloadTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(downloadTableView)
        downloadTableView.delegate = self
        downloadTableView.dataSource = self
        
        applyConstraints()
        
        fetchDownloadMovie()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Downloaded"), object: nil, queue: nil) { _ in
            self.fetchDownloadMovie()
        }
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            downloadTableView.topAnchor.constraint(equalTo: view.topAnchor),
            downloadTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            downloadTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            downloadTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    var repeatMovieSet: Set<MovieItem> = []
    var movieSet: Set<MovieItem> = []
    
    func fetchDownloadMovie() {
        DataPersistanceManager.shared.fetchData { result in
            switch result {
            case .success(let movies):
                for movie in movies {
                    if self.movieSet.contains(movie) {
                        self.repeatMovieSet.insert(movie)
                    } else {
                        self.movieSet.insert(movie)
                        self.movieItem.insert(movie, at: 0)
                    }
                }
                self.downloadTableView.reloadData()
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        let titleMovies = movieItem[indexPath.row]
        let model = TitleViewModel(titleName: titleMovies.original_title ?? titleMovies.original_name ?? "Unknow", posterURL: titleMovies.poster_path ?? "")
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataPersistanceManager.shared.deleteDownloadedMovie(model: movieItem[indexPath.row]) { results in
                switch results {
                case .success():
                    print("Movie deleted from database")
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
                self.movieItem.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = MoviePreViewController()
        vc.movie = movieItem[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
