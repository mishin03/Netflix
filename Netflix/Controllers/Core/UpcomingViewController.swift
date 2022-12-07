//
//  UpcomingViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 19.11.2022.
//

import UIKit

class UpcomingViewController: UIViewController {
    
    var titleMovies = [TitleMovie]()
    
    let upcomingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(upcomingTableView)
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        
        applyConstraints()
        
        fetchUpcoming()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            upcomingTableView.topAnchor.constraint(equalTo: view.topAnchor),
            upcomingTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            upcomingTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            upcomingTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func fetchUpcoming() {
        APICaller.shared.getUpcomingMovies { result in
            switch result {
            case .success(let titleMovies):
                self.titleMovies = titleMovies
                DispatchQueue.main.async {
                    self.upcomingTableView.reloadData()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }

}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
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
