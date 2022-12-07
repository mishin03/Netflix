//
//  HomeViewController.swift
//  Netflix
//
//  Created by Илья Мишин on 19.11.2022.
//

import UIKit

enum Sections: Int {
    case trendingMovies = 0
    case trendingTv = 1
    case popular = 2
    case upcomingMovies = 3
    case topRated = 4
}

class HomeViewController: UIViewController {
     
    private let homeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: CollectionTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private var headerView: HeroHeaderView?
    
    private var randomHeader: TitleMovie?
    
    let sectionTitles: [String] = ["Trending Movies", "Trending Tv", "Popular", "Upcoming Movies", "Top rated"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(homeTableView)
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        configureNavbar()
        
        headerView = HeroHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeTableView.tableHeaderView = headerView
        
        configureRandomHeader()
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            homeTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            homeTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func configureRandomHeader() {
        APICaller.shared.getTrendingMovies { [weak self] results in
            switch results {
            case .success(let movies):
                guard let self = self else { return }
                let titleRandom = movies.randomElement()
                self.randomHeader = titleRandom
                self.headerView?.configure(with: TitleViewModel(titleName: self.randomHeader?.original_title ?? "", posterURL: self.randomHeader?.poster_path ?? ""))
                self.headerView?.delegate = self
                self.headerView?.movie = self.randomHeader
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    private func configureNavbar() {

        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 85, height: 25))
        backButton.setBackgroundImage(UIImage(named: "netflix_logo"), for: .normal)
        let barButton = UIBarButtonItem(customView: backButton)
        NSLayoutConstraint.activate([
            (barButton.customView!.widthAnchor.constraint(equalToConstant: 85)),
            (barButton.customView!.heightAnchor.constraint(equalToConstant: 25))
        ])
        backButton.addTarget(self, action: #selector(pressLogo), for: .touchUpInside)
        navigationItem.leftBarButtonItem = barButton
        
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func pressLogo() {
        configureRandomHeader()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath) as? CollectionTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Sections.trendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { results in
                switch results {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let failure):
                    print(failure)
                }
            }
        case Sections.trendingTv.rawValue:
            APICaller.shared.getTrendingTVs { results in
                switch results {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let failure):
                    print(failure)
                }
            }
        case Sections.popular.rawValue:
            APICaller.shared.getPopular { results in
                switch results {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let failure):
                    print(failure)
                }
            }
        case Sections.upcomingMovies.rawValue:
            APICaller.shared.getUpcomingMovies { results in
                switch results {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let failure):
                    print(failure)
                }
            }
        case Sections.topRated.rawValue:
            APICaller.shared.getTopRated { results in
                switch results {
                case .success(let movies):
                    cell.configure(with: movies)
                case .failure(let failure):
                    print(failure)
                }
            }
        default:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor  = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizedFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeViewController: CollectionTableViewCellDelegate, HeroHeaderViewDelegate {
    func selected(movie: TitleMovie) {
        let vc = MoviePreViewController()
        vc.movie = movie
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pressPlayButton(movie: TitleMovie) {
        let vc = MoviePreViewController()
        vc.movie = movie
        navigationController?.pushViewController(vc, animated: true)
    }
}
