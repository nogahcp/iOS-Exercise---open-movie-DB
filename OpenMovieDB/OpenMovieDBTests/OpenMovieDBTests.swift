//
//  OpenMovieDBTests.swift
//  OpenMovieDBTests
//
//  Created by  temp on 03/11/2019.
//  Copyright © 2019  temp. All rights reserved.
//

import XCTest
@testable import OpenMovieDB

class OpenMovieDBTests: XCTestCase {

    var dataSource = MoviesDataSource()
    var detailsSource: MovieDetailsSource?
    var expectedMovies: [String] = []
    var spyDelegate = TestDelegate()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataSource = MoviesDataSource()
        expectedMovies = []
        detailsSource = nil
        //delegate
        spyDelegate = TestDelegate()
        dataSource.delegate = spyDelegate
        let expectations = expectation(description: "SomethingWithDelegate calls the delegate as the result of an async method completion")
        spyDelegate.asyncExpectation = expectations
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //check search movies names results
    func testSearch() {
        dataSource.searchMovies(for: "Lion king")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard self.spyDelegate.somethingWithDelegateAsyncResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }
            self.expectedMovies = ["The Lion King", "The Lion King", "The Lion King 2: Simba's Pride", "The Lion King 3: Hakuna Matata", "The Lion King", "Leo the Lion: King of the Jungle", "Simba: The King Lion", "The Making of 'The Lion King'", "The Lion King: A Musical Journey with Elton John", "The Lion King: Timon and Pumbaa's Jungle Games"]
            XCTAssertEqual(self.dataSource.movies.map{$0.title}, self.expectedMovies)
        }
    }
        
    
// check movies names after asking for more results
    func testGetMoreResults() {
        //ask first results
        dataSource.searchMovies(for: "Lion king")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            guard self.spyDelegate.somethingWithDelegateAsyncResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }
            //ask for more results - reset the delegate to set "somethingWithDelegateAsyncResult" property
            self.spyDelegate = TestDelegate()
            self.dataSource.delegate = self.spyDelegate
            let expectations = self.expectation(description: "SomethingWithDelegate calls the delegate as the result of an async method completion")
            self.spyDelegate.asyncExpectation = expectations
            self.dataSource.getMoreResults()
            self.waitForExpectations(timeout: 10) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                }
                
                guard self.spyDelegate.somethingWithDelegateAsyncResult != nil else {
                    XCTFail("Expected delegate to be called")
                    return
                }
                self.expectedMovies = ["The Lion King", "The Lion King", "The Lion King 2: Simba's Pride", "The Lion King 3: Hakuna Matata", "The Lion King", "Leo the Lion: King of the Jungle", "Simba: The King Lion", "The Making of 'The Lion King'", "The Lion King: A Musical Journey with Elton John", "The Lion King: Timon and Pumbaa's Jungle Games", "Son of the Lion King", "Animated StoryBook: The Lion King", "Edward VIII: The Lion King", "Broadway Backstage: The Lion King", "The Lion King Activity Center", "King Lion"]
                XCTAssertEqual(self.dataSource.movies.map{$0.title}, self.expectedMovies)
            }
        }

    }

    
    //check if retrieved details are correct
    func testGetMovieDetails() {
        self.detailsSource = MovieDetailsSource()
        detailsSource?.delegate = spyDelegate
        detailsSource?.movieIMDBId = "tt0110357"
        let expectedDetails: [String: String] = ["Title":"The Lion King",
                       "Year":"1994",
                       "Rated":"G",
                       "Released":"24 Jun 1994",
                       "Runtime":"88 min",
                       "Genre":"Animation, Adventure, Drama, Family, Musical",
                       "Director":"Roger Allers, Rob Minkoff",
                       "Writer":"Irene Mecchi (screenplay by), Jonathan Roberts (screenplay by), Linda Woolverton (screenplay by), Burny Mattinson (story), Barry Johnson (story), Lorna Cook (story), Thom Enriquez (story), Andy Gaskill (story), Gary Trousdale (story), Jim Capobianco (story), Kevin Harkey (story), Jorgen Klubien (story), Chris Sanders (story), Tom Sito (story), Larry Leker (story), Joe Ranft (story), Rick Maki (story), Ed Gombert (story), Francis Glebas (story), Mark Kausler (story), J.T. Allen (additional story material), George Scribner (additional story material), Miguel Tejada-Flores (additional story material), Jenny Tripp (additional story material), Bob Tzudiker (additional story material), Christopher Vogler (additional story material), Kirk Wise (additional story material), Noni White (additional story material), Brenda Chapman (story supervisor)",
                       "Actors":"Rowan Atkinson, Matthew Broderick, Niketa Calame-Harris, Jim Cummings",
                       "Plot":"A Lion cub crown prince is tricked by a treacherous uncle into thinking he caused his father's death and flees into exile in despair, only to learn in adulthood his identity and his responsibilities.",
                       "Language":"English, Swahili, Xhosa, Zulu",
                       "Country":"USA",
                       "Awards":"Won 2 Oscars. Another 33 wins & 29 nominations.",
                       "Poster":"https://m.media-amazon.com/images/M/MV5BYTYxNGMyZTYtMjE3MS00MzNjLWFjNmYtMDk3N2FmM2JiM2M1XkEyXkFqcGdeQXVyNjY5NDU4NzI@._V1_SX300.jpg",
                       "Ratings":"Source: Internet Movie Database Value: 8.5/10"+"\n"+"Source: Rotten Tomatoes Value: 93%"+"\n"+"Source: Metacritic Value: 88/100\n",
                       "Metascore":"88",
                       "imdbRating":"8.5",
                       "imdbVotes":"869,323",
                       "imdbID":"tt0110357",
                       "Type":"movie",
                       "DVD":"07 Oct 2003",
                       "BoxOffice":"$94,240,635",
                       "Production":"Buena Vista"]
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard self.spyDelegate.movieDetails != nil else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssertEqual(self.detailsSource?.details as! [String: String], expectedDetails)
        }
    }

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

//class to "catch" delegates
//from: https://www.mokacoding.com/blog/testing-delegates-in-swift-with-xctest/
class TestDelegate: MoviesDBModelDelegate, MovieDetailsModelDelegate {
    
    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateAsyncResult: Bool? = .none
    var movieDetails: Bool? = .none

    // Async test code needs to fulfill the XCTestExpecation used for the test
    // when all the async operations have been completed. For this reason we need
    // to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?
    
    func moviesDidChange() {
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        
        somethingWithDelegateAsyncResult = true
        expectation.fulfill()
    }
    
    func handleError(error: String) {
        return
    }
    
    func movieDetailsUpdate() {
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        
        movieDetails = true
        expectation.fulfill()
    }
}
