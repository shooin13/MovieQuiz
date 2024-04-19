import XCTest

final class MovieQuizUITests: XCTestCase {
  var app: XCUIApplication!
  
  private func tapButton(buttonAcessibilityIndicator: String, times: Int) {
    for _ in 1...times {
      app.buttons[buttonAcessibilityIndicator].tap()
      sleep(3)
    }
  }
  
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
    tapButton(buttonAcessibilityIndicator: "Yes", times: 10)
    let alert = app.alerts["QuizResultAlert"]
    let alertLabelText = alert.label
    let alertButtonText = alert.buttons.firstMatch.label
    
    XCTAssertTrue(alert.exists)
    XCTAssertTrue(alertLabelText == "Этот раунд окончен!")
    XCTAssertTrue(alertButtonText == "Сыграть еще раз")
    
    alert.buttons.firstMatch.tap()
    
    sleep(3)
    XCTAssertFalse(alert.exists)
    let indexLabel = app.staticTexts["Index"]
    XCTAssertEqual(indexLabel.label, "1/10")
  }
  
}
