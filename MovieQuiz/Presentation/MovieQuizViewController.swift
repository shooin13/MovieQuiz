import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
  //MARK: - IBOutlets
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet private weak var counterLabel: UILabel!
  
  @IBOutlet private weak var buttonsStackView: UIStackView!
  
  //MARK: - private properties
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  private let questionsAmount = 10
  private var questionFactory: QuestionFactoryProtocol?
  private var currentQuestion: QuizQuestion?
  
  //MARK: - UI Setup
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let questionFactory = QuestionFactory()
    questionFactory.delegate = self
    self.questionFactory = questionFactory
    questionFactory.requestNextQuestion()
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
    QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage() ,
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
      show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswers)/10", buttonText: "Сыграть еще раз"))
      
    } else {
      currentQuestionIndex += 1
      imageView.layer.borderColor = UIColor.clear.cgColor
      self.questionFactory?.requestNextQuestion()
    }
  }
  
  //Showing Quiz Results
  private func show(quiz result: QuizResultsViewModel) {
    let alert = UIAlertController(
      title: result.title,
      message: result.text,
      preferredStyle: .alert)
    
    let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
      //start over
      guard let self else { return }
      self.currentQuestionIndex = 0
      self.correctAnswers = 0
      questionFactory?.requestNextQuestion()
      self.imageView.layer.borderColor = UIColor.clear.cgColor
    }
    alert.addAction(action)
    self.present(alert, animated: true)
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
  
  
}
