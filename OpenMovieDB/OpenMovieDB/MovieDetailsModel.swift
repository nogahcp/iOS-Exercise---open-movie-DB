//
//  MovieDetailsModel.swift
//  OpenMovieDB
//
//  Created by  temp on 06/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MovieDetailsModel {
    var delegate: MovieDetailsModelDelegate? = nil
    //keep all relevant params for the controller
    var paramsOrder = ["Title", "Poster", "Year", "Genre"]
    //contains current movie full details
//    var detailedMovie: Movie? {
//        didSet {
//            delegate?.movieDetailsUpdate()
//        }
//    }
    
    var movieIMDBId: String = "" {
        didSet {
            self.fetchMovieData()
        }
    }
    //contains current selected movie details (in a key, value form)
    var details: [String: Any] = [:] {
        didSet {
            delegate?.movieDetailsUpdate()
        }
    }

    init(_ id: String) {
        self.movieIMDBId = id
        fetchMovieData()
    }
    
    init() {
        
    }
    
    private func getMovieDetailsUrlString(id: String) -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=\(id)&apikey=\(MoviesDBModel.APIKey)")
    }
    
    //get full details on spesific movie
    func fetchMovieData() {
//        let movieToShow = self.movies[index]
        //if current detailed movie is what we want - no need to request server
//        if self.detailedMovie?.imdbID != movieToShow.imdbID {
            //remove old detailed movie
//            self.detailedMovie = nil
            //get movie detailed data
            let detailsUrl = self.getMovieDetailsUrlString(id: self.movieIMDBId)
            let task = URLSession.shared.dataTask(with: detailsUrl!) {(data, response, error) in
                guard let data = data else { return }
                print(String(data: data, encoding: .utf8)!)
                //update data from response
                self.updateMovieDetails(from: data)
            }
            task.resume()
//        }
    }
    
    //get response from server and update movies details
    private func updateMovieDetails(from data: Data) {
        do {
            //create new movies array
            self.details = [:]
            self.paramsOrder = ["Title", "Poster", "Year", "Genre"]
            //convert data to json
            self.details = try (JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any])!
            //remove NA info
            self.details = self.details.filter { $0.value as? String != nil && $0.value as? String != "N/A" }
            //add params name to array
            Array(self.details.keys).forEach({
                if !self.paramsOrder.contains($0) {
                    self.paramsOrder.append($0)
                }
            })
            //remove response from params and details
            if let index = self.paramsOrder.firstIndex(of: "Response") { self.paramsOrder.remove(at: index) }
            if let index = self.details.index(forKey: "Response") { self.details.remove(at: index) }
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

protocol MovieDetailsModelDelegate {
    func movieDetailsUpdate()
}
