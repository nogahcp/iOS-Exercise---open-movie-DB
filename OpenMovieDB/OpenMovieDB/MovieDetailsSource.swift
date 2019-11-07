//
//  MovieDetailsModel.swift
//  OpenMovieDB
//
//  Created by  temp on 06/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MovieDetailsSource: MovieDetailsAPIDelegate {
    
    var delegate: MovieDetailsModelDelegate? = nil
    //keep all relevant params for the controller
    var paramsOrder = ["Poster", "Title", "Year", "Genre"]
    var moviesAPI = MoviesAPI()
    var movieIMDBId: String = "" {
        didSet {
            self.moviesAPI.fetchMovieData(by: movieIMDBId)
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
        self.moviesAPI.detailsDelegate = self
        self.moviesAPI.fetchMovieData(by: movieIMDBId)
    }
    
    init() {
        
    }
    
//    //get response from server and update movies details
//    private func updateMovieDetails(from data: Data) {
//        do {
//            //create new movies array
//            self.details = [:]
//            self.paramsOrder = ["Poster", "Title", "Year", "Genre"]
//            //convert data to json
//            self.details = try (JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any])!
//            //remove NA info
//            self.details = self.details.filter { $0.value as? String != "N/A" }
//            //add params name to array
//            Array(self.details.keys).forEach({
//                if !self.paramsOrder.contains($0) {
//                    self.paramsOrder.append($0)
//                }
//            })
//            //remove response from params and details
//            if let index = self.paramsOrder.firstIndex(of: "Response") { self.paramsOrder.remove(at: index) }
//            if let index = self.details.index(forKey: "Response") { self.details.remove(at: index) }
//        }
//        catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    //MovieDetailsAPIDelegate - retrieve movie details from API
    func movieDetailsResults(details: [String : Any]) {
        //create new movies array
        self.details = details
        self.paramsOrder = ["Poster", "Title", "Year", "Genre"]
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
}

protocol MovieDetailsModelDelegate {
    func movieDetailsUpdate()
}
