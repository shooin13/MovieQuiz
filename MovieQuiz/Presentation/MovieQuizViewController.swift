import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
  
  //MARK: - IBOutlets
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet weak var buttonsStackView: UIStackView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  
  //MARK: - Private properties
  
  private var alertPresenter = AlertPresenter()
  private var statisticService = StatisticServiceImplementation()
  private let moviesLoader = MoviesLoader()
  private var presenter: MovieQuizPresenter!
  

  
  //MARK: - UI Setup
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter = MovieQuizPresenter(viewController: self)
    statisticService = StatisticServiceImplementation()
    showLoadingIndicator()
    alertPresenter.delegate = self
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
    presenter.didAnswer(isCorrect: isCorrect)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      buttonsStackView.isUserInteractionEnabled = true
      presenter.showNextQuestionOrResults()
    }
  }
  
  
  //Showing Quiz Results
  func showQuizResult() {
    statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
    let alertModel = AlertModel(title: "Этот раунд окончен!",
                                message: """
                                            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
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
  
  func paintBorderWhenTheAnswerIsWrong() {
    imageView.layer.borderColor = UIColor.ypRed.cgColor
  }
  func paintBorderWhenTheAnswerIsCorrect() {
    imageView.layer.borderColor = UIColor.ypGreen.cgColor
  }
  func paintTheBorderWhenQuestionAppears() {
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  //Showing ActivityIndicator
  func showLoadingIndicator() {
    activityIndicator.startAnimating()
  }
  
  //Hiding ActivityIndicator
  func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
  }
  
  //Showing NetworkError
  func showNetworkError(message: String) {
    hideLoadingIndicator()
    alertPresenter.showAlert(AlertModel(title: "Что-то пошло не так(",
                                        message: message,
                                        buttonText: "Попробовать еще раз", 
                                        accessibilityIndicator: "NetworkErrorAlert") { [weak self] in
      guard let self else {return}
      
      presenter.loadQuestionData()
    })
  }
  
  //MARK: - AlertPresenterDelegate
  func alertPresenterDidTapButton(_ alertPresenter: AlertPresenter) {
    presenter.restartGame()
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  func viewControllerForAlertPresenting() -> UIViewController {
    return self
  }
  
}


