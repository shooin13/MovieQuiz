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
  private let moviesLoader = MoviesLoader()
  private var presenter: MovieQuizPresenter!
  
  //MARK: - UI Setup
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  func highLightImageBorder() {
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.cornerRadius = 20
  }
  

  
  //MARK: - ActivityIndicator
  func showLoadingIndicator() {
    activityIndicator.startAnimating()
  }
  
  func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter = MovieQuizPresenter(viewController: self)
    showLoadingIndicator()
    alertPresenter.delegate = self
    highLightImageBorder()
  }
  
  //MARK: - IBActions
  
  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    presenter.yesButtonClicked()
  }
  @IBAction private func noButtonClicked(_ sender: UIButton) {
    presenter.noButtonClicked()
  }
  
  // MARK: - Quiz step presentation
  
  func show(quiz step: QuizStepViewModel) {
    imageView.image = step.image
    textLabel.text = step.question
    counterLabel.text = step.questionNumber
  }
  
  // MARK: - Border indication
  
  func paintBorderWhenTheAnswerIsWrong() {
    imageView.layer.borderColor = UIColor.ypRed.cgColor
  }
  func paintBorderWhenTheAnswerIsCorrect() {
    imageView.layer.borderColor = UIColor.ypGreen.cgColor
  }
  func paintTheBorderWhenQuestionAppears() {
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  // MARK: - Quiz result presentation
  
  func showQuizResult() {
    let message = presenter.makeResultsMessage()
    let alertModel = AlertModel(title: "Этот раунд окончен!",
                                message: message,
                                buttonText: "Сыграть еще раз",
                                accessibilityIndicator: "QuizResultAlert") { [weak self] in
      guard let self else { return }
      alertPresenterDidTapButton(alertPresenter)
    }
    
    alertPresenter.showAlert(alertModel)
  }
  
  //MARK: - Network error presentation
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


