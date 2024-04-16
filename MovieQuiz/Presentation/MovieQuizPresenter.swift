import UIKit

final class MovieQuizPresenter {
  
  let questionsAmount = 10
  weak var viewController: MovieQuizViewController?
  var currentQuestion: QuizQuestion?
  
  //MARK: - Private properties
  
  private var currentQuestionIndex = 0
  
  
  //MARK: - Private methods
  
  private func operateButtonTap(givenAnswer: Bool) {
    disableButtonsInteraction()
    guard let currentQuestion else {
      return
    }
    viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  //disable buttons interaction
  private func disableButtonsInteraction() {
    viewController?.buttonsStackView.isUserInteractionEnabled = false
  }
  
  //MARK: - Custom methods
  
  //Convertion from QuizQuestion to QuizStepViewModel
  func convert(model: QuizQuestion) -> QuizStepViewModel {
    QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() ,
                      question: model.text,
                      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
  }
  
  func isLastQuestion() -> Bool {
    currentQuestionIndex == questionsAmount - 1
  }
  
  func resetQuestionIndex() {
    currentQuestionIndex = 0
  }
  
  func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
  
  func yesButtonClicked() {
    operateButtonTap(givenAnswer: true)
  }
  func noButtonClicked() {
    operateButtonTap(givenAnswer: false)
  }
  
}