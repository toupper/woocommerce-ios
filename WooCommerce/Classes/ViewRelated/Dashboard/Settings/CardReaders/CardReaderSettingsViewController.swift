import UIKit
import Yosemite
import Combine

class CardReaderSettingsViewController: UIViewController {
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        syncReaders()
    }
}

// MARK: - View Configuration
//
private extension CardReaderSettingsViewController {

    func configureNavigation() {
        title = NSLocalizedString("Card Readers", comment: "Card reader settings screen title")

        // Don't show the Settings title in the next-view's back button
        let backButton = UIBarButtonItem(title: String(),
                                         style: .plain,
                                         target: nil,
                                         action: nil)

        navigationItem.backBarButtonItem = backButton
    }

    // This should be implemented in a view model. But for brevity, we'll do it here for now
    func syncReaders() {

        let discoveryAction = CardPresentPaymentAction.startCardReaderDiscovery(onCompletion: { readers in
            print("==== readers in view controller ", readers)
        })

        ServiceLocator.stores.dispatch(discoveryAction)
    }
}
