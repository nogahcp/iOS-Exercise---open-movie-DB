//
//  MoviesDBModel.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MoviesDBModel {
    //class properties
    private var searchUrl: URL? {
        get {
            return URL(string: self.urlString)
        }
    }
    private let APIKey = "b3db097d"
    var search = ""
    private var urlString: String {
        get {
            return "https://www.omdbapi.com/?s=\(self.search)&apikey=\(self.APIKey)&page=\(self.page)"
        }
    }
    //for fetching more than 10 movies, keep trach on what page we are in sreach
    private var page = 1
    //contains all current movies answer to query - update delegate when change
    var movies:[Movie] = [] {
        didSet {
            delegate?.moviesDidChange?()
        }
    }
    //contains current movie full details
    var detailedMovie: Movie? {
        didSet {
            delegate?.movieDetailsUpdate?()
        }
    }
    //contains current selected movie details (in a key, value form)
    var details: [String: Any] = [:] {
        didSet {
            delegate?.movieDetailsUpdate?()
        }
    }
    var delegate: MoviesDBModelDelegate? = nil
    //keep all relevant params for the controller
    var paramsOrder = ["Title", "Poster", "Year", "Genre"]

    
    private func getMovieDetailsUrlString(id: String) -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=\(id)&apikey=\(self.APIKey)")
    }
    
    //new search using search string
    func searchMovies(for search: String) {
        //trim white spaces and replace others with +
        self.search = search.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
        //new search - update page to 1
        self.page = 1
        self.fetchData()
    }
    
    //fetch list of movies using the search string
    private func fetchData() {
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
            //convert data to json
            var json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            //go throw all returned movies and add to list
            if let movies = json?["Search"] as? [Any]{
                for m in movies {
                    tempArr.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
                //copy movies to real array, if not first page - add to previus array
                self.page == 1 ? self.movies = tempArr : self.movies.append(contentsOf: tempArr)
//                self.movies = tempArr
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getMoreResults() {
        self.page += 1
        self.fetchData()
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

@objc protocol MoviesDBModelDelegate {
    @objc optional func moviesDidChange()
    @objc optional func movieDetailsUpdate()
}


