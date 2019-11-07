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
            if let encodedURL = self.urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL) {
                return url
            }
            return nil
        }
    }
    static let APIKey = "b3db097d"
    var search = ""
    private var urlString: String {
        get {
            return "https://www.omdbapi.com/?s=\(self.search)&apikey=\(MoviesDBModel.APIKey)&page=\(self.page)"
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
    
    var delegate: MoviesDBModelDelegate? = nil
    
    //new search using search string
    func searchMovies(for search: String) {
        print("---> searchMovies")
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
            print(String(data: data, encoding: .utf8)! + "page: \(self.page)")
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
            //if no data retreived - if first page show nothing, show what exist
            guard json?["Response"]! as! String == "True" else {
                if self.page == 1 { self.movies = [] }
                return
            }
            //go throw all returned movies and add to list
            if let movies = json?["Search"] as? [Any]{
                for m in movies {
                    tempArr.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
                //copy movies to real array, if not first page - add to previus array
                if self.page == 1 {
                    self.movies = tempArr
                }
                else {
                    self.movies.append(contentsOf: tempArr)
                }
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
    
}

@objc protocol MoviesDBModelDelegate {
    @objc optional func moviesDidChange()
    @objc optional func movieDetailsUpdate()
}


