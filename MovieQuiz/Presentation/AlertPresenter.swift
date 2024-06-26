import UIKit

final class AlertPresenter {
  weak var delegate: AlertPresenterDelegate?
  
  func showAlert(_ alertModel: AlertModel) {
    let alert = UIAlertController(
      title: alertModel.title,
      message: alertModel.message,
      preferredStyle: .alert)
    
    
    let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
      alertModel.completion?()
    }
    
    alert.addAction(action)
    delegate?.viewControllerForAlertPresenting().present(alert, animated: true)
    
  }
  
}



