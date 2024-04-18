import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {

  //MARK: - Private properties
  
  private let questionsAmount = 10
  private var currentQuestion: QuizQuestion?
  private var correctAnswers: Int = 0
  private var alertPresenter: AlertPresenter?
  private weak var viewController: MovieQuizViewController?
  private var questionFactory: QuestionFactoryProtocol?
  private var statisticService = StatisticServiceImplementation()
  private var currentQuestionIndex = 0
  
  // MARK: - Initialization
  
  init (viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController as? MovieQuizViewController
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    guard let questionFactory = questionFactory as? QuestionFactory else { return }
    questionFactory.loadData()
    alertPresenter = AlertPresenter(delegate: self)
  }
  
  // MARK: - Button Actions
  
  func yesButtonClicked() {
    operateButtonTap(givenAnswer: true)
  }
  
  func noButtonClicked() {
    operateButtonTap(givenAnswer: false)
  }
  
  private func operateButtonTap(givenAnswer: Bool) {
    disableButtonsInteraction()
    guard let currentQuestion else {
      return
    }
    proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  private func disableButtonsInteraction() {
    viewController?.buttonsStackView.isUserInteractionEnabled = false
  }
  
  private func enableButtonsInteraction() {
    viewController?.buttonsStackView.isUserInteractionEnabled = true
  }
  
  // MARK: - Quiz Handling
  
  func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
  
  func isLastQuestion() -> Bool {
    currentQuestionIndex == questionsAmount - 1
  }
  
  func proceedToNextQuestionOrResults() {
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
  
  func proceedWithAnswer(isCorrect: Bool) {
    didAnswer(isCorrect: isCorrect)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      enableButtonsInteraction()
      proceedToNextQuestionOrResults()
    }
  }
  
  // MARK: - Data handling
  
  func convert(model: QuizQuestion) -> QuizStepViewModel {
    QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() ,
                      question: model.text,
                      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
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
  
  func didAnswer(isCorrect: Bool) {
    if isCorrect {
      correctAnswers += 1
      viewController?.paintBorderWhenTheAnswerIsCorrect()
    } else {
      viewController?.paintBorderWhenTheAnswerIsWrong()
    }
  }
  
  func makeResultsMessage() -> String {
    statisticService.store(correct: correctAnswers, total: questionsAmount)
    
    let bestGame = statisticService.bestGame
    
    let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
    let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
    let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
    + " (\(bestGame.date.dateTimeString))"
    let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
    
    let resultMessage = [
      currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
    ].joined(separator: "\n")
    
    return resultMessage
  }
  
  func loadQuestionData() {
    guard let questionFactory = questionFactory as? QuestionFactory else { return }
    questionFactory.loadData()
  }
  
  func showAlert(_ alertModel: AlertModel) {
    alertPresenter?.showAlert(alertModel)
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
  func alertPresenterDidTapButton(restart: Bool) {
    if restart {
      restartGame()
    } else {
      questionFactory?.requestNextQuestion()
    }
    
    viewController?.hideLoadingIndicator()
  }
  
  func viewControllerForAlertPresenting() -> UIViewController {
    viewController ?? MovieQuizViewController()
  }
}
