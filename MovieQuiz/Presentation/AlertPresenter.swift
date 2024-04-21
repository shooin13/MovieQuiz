import UIKit

final class AlertPresenter {
  weak var delegate: AlertPresenterDelegate?
  
  init(delegate: AlertPresenterDelegate?) {
    self.delegate = delegate
  }
  
  func showAlert(_ alertModel: AlertModel) {
    let alert = UIAlertController(
      title: alertModel.title,
      message: alertModel.message,
      preferredStyle: .alert)
    alert.view.accessibilityIdentifier = alertModel.accessibilityIndicator
    
    let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
      alertModel.completion?()
    }
    alert.addAction(action)
    let viewController = delegate?.viewControllerForAlertPresenting() as? MovieQuizViewController
    guard let viewController else { return }
    viewController.present(alert, animated: true)
  }
  
}



