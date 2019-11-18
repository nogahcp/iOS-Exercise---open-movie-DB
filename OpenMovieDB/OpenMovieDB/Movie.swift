//
//  Movie.swift
//  OpenMovieDB
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import Foundation

//stores all movie details
class Movie {
    var title = ""
    var year = ""
    var posterImage: URL?
    var imdbID = ""
    init() {
        
    }
    
    init?(json: [String: Any]) {
        guard let title = json["Title"] as? String,
            let year = json["Year"] as? String,
            let posterUrl = json["Poster"] as? String,
            let imdbID = json["imdbID"] as? String
        else {
                return nil
        }
        self.title = title
        self.year = year
        self.posterImage = URL(string: posterUrl)
        self.imdbID = imdbID
    }
}

