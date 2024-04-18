import UIKit

protocol AlertPresenterDelegate: AnyObject {
  func alertPresenterDidTapButton(restart: Bool)
    func viewControllerForAlertPresenting() -> UIViewController
      func showAlert(_ alertModel: AlertModel)
}
