import XCTest

final class MovieQuizUITests: XCTestCase {
  var app: XCUIApplication!
  
  private func prepareButtonForTestAndTestResult(buttonIndex: String) {
    sleep(3)
    
    let firstPoster = app.images["Poster"]
    let firstPosterData = firstPoster.screenshot().pngRepresentation
    
    app.buttons[buttonIndex].tap()
    sleep(3)
    
    let secondPoster = app.images["Poster"]
    let secondPosterData = secondPoster.screenshot().pngRepresentation
    
    XCTAssertFalse(firstPosterData == secondPosterData)
    
    let indexLabel = app.staticTexts["Index"]
    XCTAssertEqual(indexLabel.label, "2/10")
  }
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    app = XCUIApplication()
    app.launch()
    
    continueAfterFailure = false
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    
    app.terminate()
    app = nil
  }
  
  func testYesButton() {
    prepareButtonForTestAndTestResult(buttonIndex: "Yes")
  }
  
  func testNoButton() {
    prepareButtonForTestAndTestResult(buttonIndex: "No")
  }
  
  func testQuizResultAlertAppearedWithCorrectHeadingAndButtonText() {
    for _ in 1...10 {
      app.buttons["Yes"].tap()
      sleep(3)
    }
    let alert = app.alerts["QuizResultAlert"]
    print(alert.label)
    print(alert.buttons.firstMatch.label)
    let alertLabelText = alert.label
    let alertButtonText = alert.buttons.firstMatch.label
    
    XCTAssertTrue(alert.exists)
    XCTAssertTrue(alertLabelText == "Этот раунд окончен!")
    XCTAssertTrue(alertButtonText == "Сыграть еще раз")
  }
}
