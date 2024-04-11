import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
  
  //MARK: - IBOutlets
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet private weak var buttonsStackView: UIStackView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  
  //MARK: - Private properties
  
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  private let questionsAmount = 10
  private var questionFactory: QuestionFactoryProtocol?
  private var currentQuestion: QuizQuestion?
  private var alertPresenter = AlertPresenter()
  private var statisticService = StatisticServiceImplementation()
  private let moviesLoader = MoviesLoader()
  

  
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
    (questionFactory as! QuestionFactory).loadData()
    alertPresenter.delegate = self
  }
  
  //MARK: - IBActions
  
  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    guard let currentQuestion else {
      return
    }
    let givenAnswer = true
    buttonsStackView.isUserInteractionEnabled = false
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  @IBAction private func noButtonClicked(_ sender: UIButton) {
    guard let currentQuestion else {
      return
    }
    let givenAnswer = false
    buttonsStackView.isUserInteractionEnabled = false
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  //MARK: - Private methods
  
  //Convertion from QuizQuestion to QuizStepViewModel
  private func convert(model: QuizQuestion) -> QuizStepViewModel {
    QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage() ,
                      question: model.text,
                      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
  }
  
  //Showing question in ViewController
  private func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }
  
  //Showing the result was correct/incorrect
  private func showAnswerResult(isCorrect: Bool) {
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
      self.showNextQuestionOrResults()
      self.buttonsStackView.isUserInteractionEnabled = true
    }
  }
  
  //Showing next question or demonstrating Quiz results
  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questionsAmount - 1 {
      // go to Quiz Results
      showQuizResult()
      
    } else {
      currentQuestionIndex += 1
      imageView.layer.borderColor = UIColor.clear.cgColor
      showLoadingIndicator()
      self.questionFactory?.requestNextQuestion()
    }
  }
  
  //Showing Quiz Results
  private func showQuizResult() {
    statisticService.store(correct: correctAnswers, total: questionsAmount)
    let alertModel = AlertModel(title: "Этот раунд окончен!",
                                message: """
                                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                                            Количество сыгранных квизов: \(statisticService.gamesCount)
                                            Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
                                        """,
                                buttonText: "Сыграть еще раз") { [weak self] in
      guard let self else { return }
      alertPresenterDidTapButton(alertPresenter)
    }
    
    alertPresenter.showAlert(alertModel)
  }
  
  //Showing ActivityIndicator
  private func showLoadingIndicator() {
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
                                        buttonText: "Попробовать еще раз") { [weak self] in
      guard let self else {return}
      
      guard let questionFactory = questionFactory as? QuestionFactory else { return }
      questionFactory.loadData()
    })
  }
  
  //MARK: - QuestionFactoryDelegate
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question = question else {
      return
    }
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.show(quiz: viewModel)
    }
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
  }
  
  //MARK: - AlertPresenterDelegate
  
  func alertPresenterDidTapButton(_ alertPresenter: AlertPresenter) {
    currentQuestionIndex = 0
    correctAnswers = 0
    questionFactory?.requestNextQuestion()
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  func viewControllerForAlertPresenting() -> UIViewController {
    return self
  }
  
}


