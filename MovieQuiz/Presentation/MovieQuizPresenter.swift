import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
  
  
  
  let questionsAmount = 10
  private weak var viewController: MovieQuizViewController?
  var currentQuestion: QuizQuestion?
  private var questionFactory: QuestionFactoryProtocol?
  var correctAnswers: Int = 0
  var alertPresenter = AlertPresenter()
  
  init (viewController: MovieQuizViewController) {
    self.viewController = viewController
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    guard let questionFactory = questionFactory as? QuestionFactory else { return }
    questionFactory.loadData()
    alertPresenter.delegate = self
  }
  
  //MARK: - Private properties
  
  var currentQuestionIndex = 0
  
  
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
  
  func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
  
  func yesButtonClicked() {
    operateButtonTap(givenAnswer: true)
  }
  func noButtonClicked() {
    operateButtonTap(givenAnswer: false)
  }
  
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question = question else {
      return
    }
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.viewController?.show(quiz: viewModel)
    }
  }
  
  func showNextQuestionOrResults() {
    if self.isLastQuestion() {
      viewController?.showQuizResult()
    } else {
      self.switchToNextQuestion()
      viewController?.showLoadingIndicator()
      self.questionFactory?.requestNextQuestion()
    }
  }
  
  func restartGame() {
    correctAnswers = 0
    currentQuestionIndex = 0
    questionFactory?.requestNextQuestion()
  }
  
  func didAnswer(isCorrect: Bool) {
    if isCorrect {
      correctAnswers += 1
      viewController?.paintBorderWhenTheAnswerIsCorrect()
    } else {
      viewController?.paintBorderWhenTheAnswerIsWrong()
    }
  }
  
  //MARK: - QuestionFactoryDelegate
  func didLoadDataFromServer() {
    viewController?.hideLoadingIndicator()
    questionFactory?.requestNextQuestion()
  }
  
  func didFailToLoadData(with error: any Error) {
    viewController?.showNetworkError(message: error.localizedDescription)
  }
  
  func hideLoadingIndicatorWhenTheImageIsLoaded() {
    viewController?.hideLoadingIndicator()
    viewController?.paintTheBorderWhenQuestionAppears()
  }
  
  //MARK: - AlertPresenterDelegate
  func alertPresenterDidTapButton(_ alertPresenter: AlertPresenter) {
    restartGame()
    questionFactory?.requestNextQuestion()
    viewController?.hideLoadingIndicator()
  }
  
  func viewControllerForAlertPresenting() -> UIViewController {
    MovieQuizViewController()
  }
  
  func loadQuestionData() {
      guard let questionFactory = questionFactory as? QuestionFactory else { return }
      questionFactory.loadData()
  }
  
}
