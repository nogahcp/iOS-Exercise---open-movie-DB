//
//  MoviesAPI.swift
//  OpenMovieDB
//
//  Created by  temp on 07/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation
import Alamofire

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
    func fetchSearchQuery(search: String, page: Int) {
        //update urlString
        self.urlString = "https://www.omdbapi.com/?s=\(search)&apikey=\(self.APIKey)&page=\(page)"
        //get data from server using alamofire
        Alamofire.request(
            self.searchUrl!,
            method: .get
            ).validate()
            .responseJSON {
                [weak self] response in
                // 2
                guard let strongSelf = self else { return }
                // 3
                guard response.result.isSuccess,
                    let data = response.data else {
                        strongSelf.delegate?.handleError(error: response.result.error?.localizedDescription ?? "Error")
                        return
                }
                print(String(data: data, encoding: .utf8)!)
                //update data from response
                let moviesResult = strongSelf.parseSearchQueryResponse(from: data, at: page)
                strongSelf.delegate?.fetchResults(moviesResult: moviesResult)
        }
    }
    
    //get response from server and update list of movies
    private func parseSearchQueryResponse(from data: Data, at page: Int) -> [Movie] {
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
                return []
            }
            //go throw all returned movies and add to list
            if let jsonMovies = json?["Search"] as? [Any] {
                for m in jsonMovies {
                    tempArr.append(Movie(json: m as! [String : Any]) ?? Movie())
                }
                //notify delegate on number of results
                if let totalResults = Int((json?["totalResults"] as? String)!) {
                    self.delegate?.numberOfResults(totalResults: totalResults)
                }
                return tempArr
            }
            return []
        }
        catch let error {
            self.delegate?.handleError(error: error.localizedDescription)
        }
        return []
    }
    
    //get full details on spesific movie
    func fetchMovieData(by movieIMDBId: String) {
        //get movie detailed data
        let detailsUrl = self.getMovieDetailsUrlString(id: movieIMDBId)
        
        Alamofire.request(
            detailsUrl!,
            method: .get
            ).validate()
            .responseJSON {
                [weak self] response in
                // 2
                guard let strongSelf = self else { return }
                // 3
                guard response.result.isSuccess,
                    let data = response.data else {
                        strongSelf.detailsDelegate?.handleError(error: response.result.error?.localizedDescription ?? "Error")
                        return
                }
                print(String(data: data, encoding: .utf8)!)
                //update data from response
                let movieDetails = strongSelf.parseSearchQueryResponse(from: data)
                strongSelf.detailsDelegate?.movieDetailsResults(details: movieDetails)
        }
    }
    
    
    //get response from server and update movies details
    private func parseSearchQueryResponse(from data: Data) -> [String: Any] {
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
