//
//  MoviesAPI.swift
//  OpenMovieDB
//
//  Created by  temp on 07/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MoviesAPI {
    private var searchUrl: URL? {
        get {
            if let encodedURL = self.urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL) {
                return url
            }
            return nil
        }
    }
    private var urlString: String = ""
    private let APIKey = "b3db097d"
    //for fetching more than 10 movies, keep trach on what page we are in sreach
    var delegate: MoviesAPIDelegate? = nil
    var detailsDelegate: MovieDetailsAPIDelegate? = nil
    private func getMovieDetailsUrlString(id: String) -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=\(id)&apikey=\(self.APIKey)")
    }
    
    //fetch list of movies using the search string
    func fetchData(search: String, page: Int, into movies: [Movie]) {
        //update urlString
        self.urlString = "https://www.omdbapi.com/?s=\(search)&apikey=\(self.APIKey)&page=\(page)"
        //get data from server
        let task = URLSession.shared.dataTask(with: searchUrl!) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            //update data from response
            let moviesResult = self.updateMovies(from: data, into: movies, at: page)
            self.delegate?.fetchResults(moviesResult: moviesResult)
        }
        task.resume()
    }
    
    //get response from server and update list of movies
    private func updateMovies(from data: Data, into movies: [Movie], at page: Int) -> [Movie] {
        do {
            //create new movies array
            var tempArr: [Movie] = []
            //convert data to json
            var json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
            //if no data retreived - if first page show nothing, show what exist
            guard json?["Response"]! as! String == "True" else {
                //if data contains error - sent to delegate
                if let erorrMessage = json?["Error"] as? String {
                    self.delegate?.handleError(error: erorrMessage)
                }
                if page == 1 {
                    return []
                }
                return movies
            }
            //go throw all returned movies and add to list
            if let jsonMovies = json?["Search"] as? [Any] {
                for m in jsonMovies {
                    tempArr.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
                //copy movies to real array, if not first page - add to previus array
                if page == 1 {
                    //notify delegate on number of results
                    if let totalResults = Int((json?["totalResults"] as? String)!) {
                        self.delegate?.numberOfResults(totalResults: totalResults)
                    }
                    return tempArr
                }
                else {
                    var copy = movies
                    copy.append(contentsOf: tempArr)
                    return copy
                }
            }
            return movies
        }
        catch let error {
//            print(error.localizedDescription)
            self.delegate?.handleError(error: error.localizedDescription)
        }
        return movies
    }
    
    //get full details on spesific movie
    func fetchMovieData(by movieIMDBId: String) {
        //get movie detailed data
        let detailsUrl = self.getMovieDetailsUrlString(id: movieIMDBId)
        let task = URLSession.shared.dataTask(with: detailsUrl!) {(data, response, error) in
            guard let data = data else {
                //on error senf to delegate
                if let errorMessege = error?.localizedDescription {
                    self.detailsDelegate?.handleError(error: errorMessege)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            //update data from response
            let movieDetails = self.updateMovieDetails(from: data)
            self.detailsDelegate?.movieDetailsResults(details: movieDetails)
        }
        task.resume()
    }
    
    
    //get response from server and update movies details
    private func updateMovieDetails(from data: Data) -> [String: Any] {
        do {
            //convert data to json
            var details = try (JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any])!
            //check if error - notify delegate
            if let errorMessege = details["Error"] as? String {
                self.detailsDelegate?.handleError(error: errorMessege)
            }
            //remove NA info
            details = details.filter { $0.value as? String != "N/A" }
            return details
        }
        catch let error {
            self.detailsDelegate?.handleError(error: error.localizedDescription)
        }
        return [:]
    }
}

protocol MoviesAPIDelegate {
    func fetchResults(moviesResult: [Movie])
    func numberOfResults(totalResults: Int)
    func handleError(error: String)
}

protocol MovieDetailsAPIDelegate {
    func movieDetailsResults(details: [String: Any])
    func handleError(error: String)
}
