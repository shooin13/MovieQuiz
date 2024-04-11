import Foundation
class QuestionFactory: QuestionFactoryProtocol {
  
  private let moviesLoader: MoviesLoading
  private weak var delegate: QuestionFactoryDelegate?
  
  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }
  
  private var movies: [MostPopularMovie] = []
  
  private struct CustomNetworkError: LocalizedError {
    var errorDescription: String?
    init(errorDescription: String) {
      self.errorDescription = errorDescription
    }
  }
  
  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      let index = (0..<self.movies.count).randomElement() ?? 0
      
      guard let movie = self.movies[safe: index] else {
        return
      }
      
      var imageData = Data()
      
      do {
        imageData = try Data(contentsOf: movie.resizedImageURL)
      } catch {
        print("Failed to load image")
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          self.delegate?.didFailToLoadData(with: CustomNetworkError(errorDescription: "Невозможно загрузить данные") )
        }
      }
      
      let rating = Float(movie.rating) ?? 0
      
      let text = "Рейтинг этого фильма больше чем 7?"
      let correctAnswer = rating > 7
      
      let question = QuizQuestion(image: imageData,
                                  text: text,
                                  correctAnswer: correctAnswer)
      
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.delegate?.hideLoadingIndicatorWhenTheImageIsLoaded()
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
  
  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self else { return }
        switch result {
        case .success(let mostPopularMovies):
          self.movies = mostPopularMovies.items
          self.delegate?.didLoadDataFromServer()
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error)
        }
      }
    }
  }
}
