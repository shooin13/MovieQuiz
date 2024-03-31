import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func alertPresenterDidTapButton(_ alertPresenter: AlertPresenter)
    func viewControllerForAlertPresenting() -> UIViewController
}
