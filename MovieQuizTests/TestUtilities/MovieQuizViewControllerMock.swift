
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
  func show(quiz step: QuizStepViewModel) {}
  
  func showQuizResult() {}
  
  func highlightImageBorder() {}
  
  func showLoadingIndicator() {}
  
  func hideLoadingIndicator() {}
  
  func showNetworkError(message: String) {}
  
  func enableUI() {}
  
  func disableUI() {}
  
  func paintBorderWhenTheAnswerIsCorrect() {}
  
  func paintBorderWhenTheAnswerIsWrong() {}
  
  func paintTheBorderWhenQuestionAppears() {}
}
