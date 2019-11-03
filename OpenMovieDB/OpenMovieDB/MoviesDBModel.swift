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
    var search = "search"
    private var urlString: String {
        get {
            return "https://www.omdbapi.com/?s=\(self.search)&apikey=\(self.APIKey)"
        }
    }
    
    var movies:[Movie] = []
    
    init() {
        self.fetchData(for: "Lion")
    }
    
    func fetchData(for search: String) {
        self.search = search
        //TODO - NOT ON MAIN THREAD
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
            //convert data to json
            var json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            //go throw all returned movies and add to list
            if let movies = json?["Search"] as? [Any]{
                for m in movies {
                    self.movies.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        
    }
    
}

