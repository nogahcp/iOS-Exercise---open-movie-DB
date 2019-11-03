//
//  MoviesDBModel.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MoviesDBModel {
    lazy private var searchUrl = URL(string: self.urlString)

    private let APIKey = "b3db097d"
    var search = ""
    private var urlString: String {
        get {
            return "https://www.omdbapi.com/?s=\(self.search)&apikey=\(self.APIKey)&page=1"
        }
    }
    private func getMovieDetailsUrlString(id: String) -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=\(id)&apikey=\(self.APIKey)")
    }
    
    //contains all current movies answer to query
    var movies:[Movie] = []
    //contains current movie full details
    var detailedMovie: Movie?
    var details: [String: Any] = [:]
    
    init() {
        self.fetchData(for: "lion")
    }
    
    func fetchData(for search: String) {
        self.search = search
        //get data from server
        let task = URLSession.shared.dataTask(with: searchUrl!) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            //update data from response
            self.updateMovies(from: data)
        }
        task.resume()
    }
    
    //get response from server and update list of movies
    private func updateMovies(from data: Data) {
        do {
            //create new movies array
            var tempArr: [Movie] = []
            self.movies = []
            //convert data to json
            var json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            //go throw all returned movies and add to list
            if let movies = json?["Search"] as? [Any]{
                for m in movies {
                    tempArr.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
                //copy movies to real array
                self.movies = tempArr
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    //get full details on spesific movie
    func fetchMovieData(at index: Int) {
        let movieToShow = self.movies[index]
        //if current detailed movie is what we want - no need to request server
        if self.detailedMovie?.imdbID != movieToShow.imdbID {
            //remove old detailed movie
            self.detailedMovie = nil
            //get movie detailed data
            let detailsUrl = self.getMovieDetailsUrlString(id: movieToShow.imdbID)
            let task = URLSession.shared.dataTask(with: detailsUrl!) {(data, response, error) in
                guard let data = data else { return }
                print(String(data: data, encoding: .utf8)!)
                //update data from response
                self.updateMovieDetails(from: data)
            }
            task.resume()
        }
    }
    
    //get response from server and update list of movies
    private func updateMovieDetails(from data: Data) {
        do {
            //create new movies array
            self.details = [:]
            //convert data to json
            self.details = try (JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any])!
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
}

