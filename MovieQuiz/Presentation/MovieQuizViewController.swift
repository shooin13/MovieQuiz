import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
  
  //MARK: - IBOutlets
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet weak var buttonsStackView: UIStackView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  
  //MARK: - Private properties
  
  private var correctAnswers = 0
  private var questionFactory: QuestionFactoryProtocol?
  private var alertPresenter = AlertPresenter()
  private var statisticService = StatisticServiceImplementation()
  private let moviesLoader = MoviesLoader()
  private let presenter = MovieQuizPresenter()
  

  
  //MARK: - UI Setup
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    statisticService = StatisticServiceImplementation()
    showLoadingIndicator()
    guard let questionFactory = questionFactory as? QuestionFactory else { return }
    questionFactory.loadData()
    alertPresenter.delegate = self
    presenter.viewController = self
  }
  
  //MARK: - IBActions
  
  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    presenter.yesButtonClicked()
  }
  @IBAction private func noButtonClicked(_ sender: UIButton) {
    presenter.noButtonClicked()
  }
  
  //MARK: - Private methods
  
  //Showing question in ViewController
  func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }
  
  //Showing the result was correct/incorrect
  func showAnswerResult(isCorrect: Bool) {
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.cornerRadius = 20
    if isCorrect {
      imageView.layer.borderColor = UIColor.ypGreen.cgColor
      correctAnswers += 1
    } else {
      imageView.layer.borderColor = UIColor.ypRed.cgColor
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      buttonsStackView.isUserInteractionEnabled = true
      self.presenter.correctAnswers = self.correctAnswers
      self.presenter.questionFactory = self.questionFactory
      presenter.showNextQuestionOrResults()
    }
  }
  
  //Showing next question or demonstrating Quiz results
//  private func showNextQuestionOrResults() {
//    if presenter.isLastQuestion() {
//      // go to Quiz Results
//      showQuizResult()
//      
//    } else {
//      presenter.switchToNextQuestion()
//      showLoadingIndicator()
//      self.questionFactory?.requestNextQuestion()
//    }
//  }
  
  //Showing Quiz Results
  func showQuizResult() {
    statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
    let alertModel = AlertModel(title: "Этот раунд окончен!",
                                message: """
                                            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                                            Количество сыгранных квизов: \(statisticService.gamesCount)
                                            Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
                                        """,
                                buttonText: "Сыграть еще раз", 
                                accessibilityIndicator: "QuizResultAlert") { [weak self] in
      guard let self else { return }
      alertPresenterDidTapButton(alertPresenter)
    }
    
    alertPresenter.showAlert(alertModel)
  }
  
  //Showing ActivityIndicator
  func showLoadingIndicator() {
    activityIndicator.startAnimating()
  }
  
  //Hiding ActivityIndicator
  private func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
  }
  
  //Showing NetworkError
  private func showNetworkError(message: String) {
    hideLoadingIndicator()
    alertPresenter.showAlert(AlertModel(title: "Что-то пошло не так(",
                                        message: message,
                                        buttonText: "Попробовать еще раз", 
                                        accessibilityIndicator: "NetworkErrorAlert") { [weak self] in
      guard let self else {return}
      
      guard let questionFactory = questionFactory as? QuestionFactory else { return }
      questionFactory.loadData()
    })
  }
  
  //MARK: - QuestionFactoryDelegate
  func didReceiveNextQuestion(question: QuizQuestion?) {
    presenter.didReceiveNextQuestion(question: question)
  }
  
  func didLoadDataFromServer() {
    hideLoadingIndicator()
    questionFactory?.requestNextQuestion()
  }
  
  func didFailToLoadData(with error: any Error) {
    showNetworkError(message: error.localizedDescription)
  }
  
  func hideLoadingIndicatorWhenTheImageIsLoaded() {
    hideLoadingIndicator()
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  //MARK: - AlertPresenterDelegate
  
  func alertPresenterDidTapButton(_ alertPresenter: AlertPresenter) {
    presenter.resetQuestionIndex()
    correctAnswers = 0
    questionFactory?.requestNextQuestion()
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  func viewControllerForAlertPresenting() -> UIViewController {
    return self
  }
  
}


