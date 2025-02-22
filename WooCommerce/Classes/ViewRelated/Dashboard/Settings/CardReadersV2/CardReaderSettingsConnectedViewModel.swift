import Combine
import Foundation
import Yosemite

final class CardReaderSettingsConnectedViewModel: CardReaderSettingsPresentedViewModel {
    private(set) var shouldShow: CardReaderSettingsTriState = .isUnknown
    var didChangeShouldShow: ((CardReaderSettingsTriState) -> Void)?
    var didUpdate: (() -> Void)?

    private var didGetConnectedReaders: Bool = false
    private var connectedReaders = [CardReader]()
    private let knownReaderProvider: CardReaderSettingsKnownReaderProvider?

    private(set) var readerUpdateAvailable: Bool = false
    var readerUpdateInProgress: Bool {
        readerUpdateProgress != nil
    }
    private(set) var readerUpdateProgress: Float? = nil
    private(set) var readerUpdateError: Error? = nil
    private var softwareUpdateCancelable: FallibleCancelable? = nil

    private(set) var readerDisconnectInProgress: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    var connectedReaderID: String?
    var connectedReaderBatteryLevel: String?
    var connectedReaderSoftwareVersion: String?

    init(didChangeShouldShow: ((CardReaderSettingsTriState) -> Void)?, knownReaderProvider: CardReaderSettingsKnownReaderProvider? = nil) {
        self.didChangeShouldShow = didChangeShouldShow
        self.knownReaderProvider = knownReaderProvider
        beginObservation()
    }

    /// Dispatches actions to the CardPresentPaymentStore so that we can monitor changes to the list of
    /// connected readers.
    ///
    private func beginObservation() {
        // This completion should be called repeatedly as the list of connected readers changes
        let action = CardPresentPaymentAction.observeConnectedReaders() { [weak self] readers in
            guard let self = self else {
                return
            }
            self.didGetConnectedReaders = true
            self.connectedReaders = readers
            self.updateProperties()
            self.reevaluateShouldShow()
        }
        ServiceLocator.stores.dispatch(action)

        let softwareUpdateAction = CardPresentPaymentAction.observeCardReaderUpdateState { softwareUpdateEvents in
            softwareUpdateEvents
                .sink { [weak self] state in
                    guard let self = self else { return }

                    switch state {
                    case .started(cancelable: let cancelable):
                        self.readerUpdateError = nil
                        self.softwareUpdateCancelable = cancelable
                        self.readerUpdateProgress = 0
                        ServiceLocator.analytics.track(.cardReaderSoftwareUpdateStarted)
                    case .installing(progress: let progress):
                        self.readerUpdateProgress = progress
                    case .failed(error: let error):
                        if case CardReaderServiceError.softwareUpdate(underlyingError: let underlyingError, batteryLevel: _) = error,
                           underlyingError == .readerSoftwareUpdateFailedInterrupted {
                            // Update was cancelled, don't treat this as an error
                            break
                        }
                        self.readerUpdateError = error
                        self.completeCardReaderUpdate(success: false)
                        ServiceLocator.analytics.track(.cardReaderSoftwareUpdateFailed)
                    case .completed:
                        self.readerUpdateProgress = 1
                        self.softwareUpdateCancelable = nil
                        ServiceLocator.analytics.track(.cardReaderSoftwareUpdateSuccess)
                        // If we were installing a software update, introduce a small delay so the user can
                        // actually see a success message showing the installation was complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                            self?.completeCardReaderUpdate(success: true)
                        }
                    case .available:
                        self.readerUpdateAvailable = true
                    case .none:
                        self.readerUpdateAvailable = false
                    }
                    self.didUpdate?()
                }
                .store(in: &self.subscriptions)
        }
        ServiceLocator.stores.dispatch(softwareUpdateAction)
    }

    private func updateProperties() {
        updateReaderID()
        updateBatteryLevel()
        updateSoftwareVersion()
    }

    private func updateReaderID() {
        connectedReaderID = connectedReaders.first?.id
    }

    private func updateBatteryLevel() {
        guard let batteryLevel = connectedReaders.first?.batteryLevel else {
            connectedReaderBatteryLevel = Localization.unknownBatteryStatus
            return
        }

        let batteryLevelPercent = Int(100 * batteryLevel)
        let batteryLevelString = NumberFormatter.localizedString(from: batteryLevelPercent as NSNumber, number: .decimal)
        connectedReaderBatteryLevel = String.localizedStringWithFormat(Localization.batteryLabelFormat, batteryLevelString)
    }

    private func updateSoftwareVersion() {
        guard let softwareVersion = connectedReaders.first?.softwareVersion else {
            connectedReaderSoftwareVersion = Localization.unknownSoftwareVersion
            return
        }

        connectedReaderSoftwareVersion = String.localizedStringWithFormat(Localization.versionLabelFormat, softwareVersion)
    }

    /// Allows the view controller to kick off a card reader update
    ///
    func startCardReaderUpdate() {
        ServiceLocator.analytics.track(.cardReaderSoftwareUpdateTapped)
        let action = CardPresentPaymentAction.startCardReaderUpdate
        ServiceLocator.stores.dispatch(action)
    }

    func cancelCardReaderUpdate() {
        ServiceLocator.analytics.track(.cardReaderSoftwareUpdateCancelTapped)
        softwareUpdateCancelable?.cancel(completion: { [weak self] result in
            if case .failure(let error) = result {
                print("=== error canceling software update: \(error)")
            } else {
                self?.completeCardReaderUpdate(success: false)
                ServiceLocator.analytics.track(.cardReaderSoftwareUpdateCanceled)
            }
        })
    }

    func dismissReaderUpdateError() {
        readerUpdateError = nil
        didUpdate?()
    }

    private func completeCardReaderUpdate(success: Bool) {
        readerUpdateAvailable = !success
        readerUpdateProgress = nil
        didUpdate?()
    }

    /// Dispatch a request to disconnect from a reader
    ///
    func disconnectReader() {
        ServiceLocator.analytics.track(.cardReaderDisconnectTapped)

        self.readerDisconnectInProgress = true
        self.didUpdate?()

        knownReaderProvider?.forgetCardReader()

        let action = CardPresentPaymentAction.disconnect() { result in
            self.readerDisconnectInProgress = false
            self.didUpdate?()

            guard result.isSuccess else {
                DDLogError("Unexpected error when disconnecting reader")
                return
            }
        }
        ServiceLocator.stores.dispatch(action)
    }

    /// Updates whether the view this viewModel is associated with should be shown or not
    /// Notifes the viewModel owner if a change occurs via didChangeShouldShow
    ///
    private func reevaluateShouldShow() {
        var newShouldShow: CardReaderSettingsTriState = .isUnknown

        if !didGetConnectedReaders {
            newShouldShow = .isUnknown
        } else if connectedReaders.isEmpty {
            newShouldShow = .isFalse
        } else {
            newShouldShow = .isTrue
        }

        let didChange = newShouldShow != shouldShow

        shouldShow = newShouldShow

        if didChange {
            didChangeShouldShow?(shouldShow)
        }
    }
}

// MARK: - Localization
//
private extension CardReaderSettingsConnectedViewModel {
    enum Localization {
        static let title = NSLocalizedString(
            "Connected Reader",
            comment: "Settings > Manage Card Reader > Connected Reader Table Section Heading"
        )

        static let unknownBatteryStatus = NSLocalizedString(
            "Unknown Battery Level",
            comment: "Displayed in the unlikely event a card reader has an indeterminate battery status"
        )

        static let batteryLabelFormat = NSLocalizedString(
            "%1$@%% Battery",
            comment: "Card reader battery level as an integer percentage"
        )

        static let unknownSoftwareVersion = NSLocalizedString(
            "Unknown Software Version",
            comment: "Displayed in the unlikely event a card reader has an indeterminate software version"
        )

        static let versionLabelFormat = NSLocalizedString(
            "Version: %1$@",
            comment: "Displays the connected reader software version"
        )
    }
}
