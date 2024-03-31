import UIKit

class AlertPresenter {
  weak var delegate: AlertPresenterDelegate?
  
  func showAlert(_ alertModel: AlertModel) {
    let alert = UIAlertController(
      title: alertModel.title,
      message: alertModel.message,
      preferredStyle: .alert)
    
    let action = UIAlertAction(title: alertModel.buttonText, style: .default) { [weak self] _ in
      guard let self else { return }
      delegate?.alertPresenterDidTapButton(self)
    }
    
    alert.addAction(action)
    delegate?.viewControllerForAlertPresenting().present(alert, animated: true)
    
  }
  
}



