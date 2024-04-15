import UIKit

final class MovieQuizPresenter {
  
  //MARK: - Private properties
  let questionsAmount = 10
  private var currentQuestionIndex = 0
  
  
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
  
}
