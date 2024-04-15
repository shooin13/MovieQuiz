import XCTest

struct ArithmeticOperations {
  func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      handler(num1  + num2)
    }
  }
  
  func subtraction(num1: Int, num2: Int) -> Int {
    num1 - num2
  }
  
  func multiplication(num1: Int, num2: Int) -> Int {
    num1 * num2
  }
}

final class MovieQuizTests: XCTestCase {
  
  override func setUpWithError() throws {
    
  }
  
  override func tearDownWithError() throws {
    
  }
  
  func testAddition() throws {
    let arithmeticOperations = ArithmeticOperations()
    let num1 = 1
    let num2 = 2
    
    arithmeticOperations.addition(num1: num1, num2: num2) { result in
      XCTAssertEqual(result, 4)
    }
  }
  
  func testSubtraction() throws {
    let arithmeticOperations = ArithmeticOperations()
    let num1 = 5
    let num2 = 3
    
    let result = arithmeticOperations.subtraction(num1: num1, num2: num2)
    
    XCTAssertEqual(result, 2)
  }
  
  func testPerformanceExample() throws {
    
    measure {
      
    }
  }
  
}
