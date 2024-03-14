import UIKit

final class MovieQuizViewController: UIViewController {
  //MARK: - IBOutlets
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var textLabel: UILabel!
  @IBOutlet private weak var counterLabel: UILabel!
  
  @IBOutlet private weak var buttonsStackView: UIStackView!
  
  //MARK: - private properties
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  
  //MARK: - UI Setup
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let currentQuestion = questions[currentQuestionIndex]
    show(quiz: convert(model: currentQuestion))
  }
  
  //MARK: - IBActions
  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    let currentQuestion = questions[currentQuestionIndex]
    let givenAnswer = true
    buttonsStackView.isUserInteractionEnabled = false
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  @IBAction private func noButtonClicked(_ sender: UIButton) {
    let currentQuestion = questions[currentQuestionIndex]
    let givenAnswer = false
    buttonsStackView.isUserInteractionEnabled = false
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  //MARK: - Models
  private struct QuizQestion {
    let image: String
    let text: String
    let correctAnswer: Bool
  }
  
  private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
  }
  
  private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
  }
  
  //MARK: - Private methods
  //Convertion from QuizQuestion to QuizStepViewModel
  private func convert(model: QuizQestion) -> QuizStepViewModel {
    QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage() , 
                      question: model.text,
                      questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.showNextQuestionOrResults()
      self.buttonsStackView.isUserInteractionEnabled = true
    }
  }
  
  //Showing next question or demonstrating Quiz results
  private func showNextQuestionOrResults() {
    if currentQuestionIndex == questions.count - 1 {
      // go to Quiz Results
      show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswers)/10", buttonText: "Сыграть еще раз"))

    } else {
      currentQuestionIndex += 1
      imageView.layer.borderColor = UIColor.clear.cgColor
      let nextQuestion = questions[currentQuestionIndex]
      let viewModel = convert(model: nextQuestion)
      show(quiz: viewModel)
    }
  }
  
  //Showing Quiz Results
  private func show(quiz result: QuizResultsViewModel) {
    let alert = UIAlertController(
      title: result.title,
      message: result.text,
      preferredStyle: .alert)
    
    let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
      //start over
      self.currentQuestionIndex = 0
      self.correctAnswers = 0
      
      let firstQuestion = self.questions[self.currentQuestionIndex]
      let viewModel = self.convert(model: firstQuestion)
      self.show(quiz: viewModel)
      self.imageView.layer.borderColor = UIColor.clear.cgColor
    }
    alert.addAction(action)
    self.present(alert, animated: true)
  }
  
  //MARK: - Mock data
  private let questions: [QuizQestion] = [
    QuizQestion(
      image: "The Godfather",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "The Dark Knight",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "Kill Bill",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "The Avengers",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "Deadpool",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "The Green Knight",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: true),
    QuizQestion(
      image: "Old",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: false),
    QuizQestion(
      image: "The Ice Age Adventures of Buck Wild",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: false),
    QuizQestion(
      image: "Tesla",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: false),
    QuizQestion(
      image: "Vivarium",
      text: "Рейтинг этого фильма больше чем 6?",
      correctAnswer: false)
  ]
}
