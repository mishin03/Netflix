//
//  DataPersistanceManager.swift
//  Netflix
//
//  Created by Илья Мишин on 25.11.2022.
//

import UIKit
import CoreData

class DataPersistanceManager {
    
    static let shared = DataPersistanceManager()
    
    enum DataBaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    func downloadMovieWith(model: TitleMovie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let contex = appDelegate.persistentContainer.viewContext
        
        let item = MovieItem(context: contex)
        
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.media_type = model.media_type
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average
                
        do {
            try contex.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToSaveData))
        }
    }
    
    func fetchData(completion: @escaping (Result<[MovieItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let contex = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<MovieItem>
        
        request = MovieItem.fetchRequest()
        
        do {
            let movies = try contex.fetch(request)
            completion(.success(movies))
        } catch {
            completion(.failure(DataBaseError.failedToFetchData))
        }
    }
    
    func deleteDownloadedMovie(model: MovieItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let contex = appDelegate.persistentContainer.viewContext
        
        contex.delete(model)
        do {
            try contex.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToDeleteData))
        }
    }
}
