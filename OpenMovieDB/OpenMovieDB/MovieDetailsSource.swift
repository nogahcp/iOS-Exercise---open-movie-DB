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
    var details: [String: Any] = [:]

    init(_ id: String) {
        self.movieIMDBId = id
        self.moviesAPI.detailsDelegate = self
        self.moviesAPI.fetchMovieData(by: movieIMDBId)
    }
    
    init() {
        
    }
    
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
        //parse details into [String:String] dictionary
        self.parseDetails()
    }
    
    //parse details from [String:Any] to a [String: Satring] dictionary
    private func parseDetails() {
        var resultDetails: [String: String] = [:]
        for (param, paramValue) in self.details {
            //try convert value to string (most values)
            if let currInfo = paramValue as? String {
                resultDetails[param] = currInfo
            }
            //if did not convert to string try convert to array of dictionaries (in scores)
            else
            {
                if let currInfo = paramValue as? [[String: String]] {
                    var paramValueAsString = ""
                    for dic in currInfo { //res is [String: String]
                        //sort dictionary ao all dictionaries will be the same order
                        let sortedKeysAndValues = (dic.sorted(by: { $0.0 < $1.0 } ))
                        //convert to string: Key1: Value1 Key2: Value2
                        let resString = (sortedKeysAndValues.compactMap({ (dicKey, dicValue) -> String in
                            return "\(dicKey): \(dicValue)"
                        }) as Array).joined(separator: " ")
                        paramValueAsString.append(resString+"\n")
                    }
                    //add string that represents dictionary as current param valus
                    resultDetails[param] = paramValueAsString
                }
            }
        }
        self.details = resultDetails
        self.delegate?.movieDetailsUpdate()
    }
}

protocol MovieDetailsModelDelegate {
    func movieDetailsUpdate()
}
