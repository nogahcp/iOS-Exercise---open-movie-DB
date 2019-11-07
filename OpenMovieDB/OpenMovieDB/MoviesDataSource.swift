//
//  MoviesDBModel.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

class MoviesDataSource: MoviesAPIDelegate {
    
    var moviesAPI = MoviesAPI()
    //class properties
    var search = ""
    //contains all current movies answer to query - update delegate when change
    var movies:[Movie] = []
    var page = 1
    var numberOfRemainingResults = 0 //in order to ask for more results only if more results existx
    var delegate: MoviesDBModelDelegate? = nil
    
    init() {
        //API delegate - notify when data is retreive
        self.moviesAPI.delegate = self
    }
    
    //new search using search string
    func searchMovies(for search: String) {
        print("---> searchMovies")
        //trim white spaces and replace others with +
        self.search = search.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
        //new search - update page to 1, and number of reamaining results to 0
        self.page = 1
        self.numberOfRemainingResults = 0
        self.getMoviesFromServer()
    }
    
    func getMoreResults() {
        if self.numberOfRemainingResults > 0 {
            self.page += 1
            self.getMoviesFromServer()
        }
    }
    
    //ask API to fetch movies according to search
    private func getMoviesFromServer() {
        self.moviesAPI.fetchData(search: self.search, page: self.page, into: self.movies)
    }
    
    //MoviesAPIDelegate - notify that movies result retreived
    func fetchResults(moviesResult: [Movie]) {
        //reduce number of new results from "numberOfRemainingResults"
        let reduce = self.movies.count - moviesResult.count
        self.numberOfRemainingResults += reduce
        
        self.movies = moviesResult
        //notify delegate about change
        delegate?.moviesDidChange()
    }
    
    //MoviesAPIDelegate - when new search is done - notify about number of total results
    func numberOfResults(totalResults: Int) {
        self.numberOfRemainingResults = totalResults
    }
    
    //MoviesAPIDelegate - when got error - senf to delegate
    func handleError(error: String) {
        self.delegate?.handleError(error: error)
    }
    
}

protocol MoviesDBModelDelegate {
    func moviesDidChange()
    func handleError(error: String)
}


