import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
  func testSuccessLoading() throws {
    
    let stubNetworkClient = StubNetworkClient(emulateError: false)
    let loader = MoviesLoader(networkClient: stubNetworkClient)
    
    let expectation = expectation(description: "Loading expectation")
    
    loader.loadMovies { result in
      switch result {
      case .success(let movies):
        expectation.fulfill()
      case .failure(_):
        XCTFail("Unexpected failure")
      }
    }
    waitForExpectations(timeout: 1)
  }
  
  func testFailureLoading() throws {
    
    let stubNetworkClient = StubNetworkClient(emulateError: true)
    let loader = MoviesLoader(networkClient: stubNetworkClient)
    
    let expectation = expectation(description: "Failure expectationz")
    
    loader.loadMovies { result in
      switch result {
      case .success(_):
        XCTFail("Failure. Data was loaded")
      case .failure(let error):
        expectation.fulfill()
        XCTAssertNotNil(error)
      }
    }
    waitForExpectations(timeout: 1)
  }
}
