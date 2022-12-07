//
//  APICaller.swift
//  Netflix
//
//  Created by Илья Мишин on 22.11.2022.
//

import UIKit

struct Constants {
    static let api_key = "8ef8c5357bb8fe4f9aed3c9553d8ee88"
    static let baseURL = "https://api.themoviedb.org"
    static let YouTubeAPI_key = "AIzaSyAJdPCJ1r-lqTuyUQded3Ua-6o3ii5uzSo"
    static let YouTubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    static let shared = APICaller()
    
    func getTrendingMovies(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/all/day?api_key=\(Constants.api_key)") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getTrendingTVs(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/tv/day?api_key=\(Constants.api_key)") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getUpcomingMovies(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
            guard let url = URL(string: "\(Constants.baseURL)/3/movie/upcoming?api_key=\(Constants.api_key)&language=en-US&page=1") else {return}
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                    completion(.success(results.results))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
        
        func getPopular(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
            guard let url = URL(string: "\(Constants.baseURL)/3/movie/popular?api_key=\(Constants.api_key)&language=en-US&page=1") else {return}
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                    completion(.success(results.results))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            
            task.resume()
        }
    
    func getTopRated(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/top_rated?api_key=\(Constants.api_key)&language=en-US&page=1") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getDiscovered(completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.api_key)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getSearched(with query: String, completion: @escaping (Result<[TitleMovie], Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.api_key)&query=\(query)") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(TitleResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func youtubeSearch(with query: String, completion: @escaping (Result<VideoElements, Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return}
        guard let url = URL(string: "\(Constants.YouTubeBaseURL)q=\(query)&key=\(Constants.YouTubeAPI_key)") else {return}
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let results = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
                
                completion(.success(results.items[0]))
            } catch {
                completion(.failure(error))
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
