import UIKit

protocol AlertPresenterDelegate: AnyObject {
  func alertPresenterDidTapButton(restart: Bool)
  func viewControllerForAlertPresenting() -> MovieQuizViewControllerProtocol
  func showAlert(_ alertModel: AlertModel)
}
