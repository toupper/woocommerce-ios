import UIKit
import Yosemite

protocol SwitchStoreUseCaseProtocol {
    func switchStore(with storeID: Int64, onCompletion: @escaping (Bool) -> Void)
}

/// Simplifies and decouples the store picker from the caller
///
final class SwitchStoreUseCase: SwitchStoreUseCaseProtocol {

    private let stores: StoresManager

    init(stores: StoresManager) {
        self.stores = stores
    }

    /// A static method which allows easily to switch store. The boolean argument in `onCompletion` indicates that the site was changed.
    /// When `onCompletion` is called, the selected site ID is updated while `Site` might still not be available if the site does not exist in storage yet
    /// (e.g. a newly connected site).
    ///
    func switchStore(with storeID: Int64, onCompletion: @escaping (Bool) -> Void) {
        guard storeID != stores.sessionManager.defaultStoreID else {
            onCompletion(false)
            return
        }

        // This method doesn't use `[weak self]` because of this
        // https://github.com/woocommerce/woocommerce-ios/pull/2013#discussion_r454620804
        logOutOfCurrentStore {
            self.finalizeStoreSelection(storeID)

            // Reload orders badge
            NotificationCenter.default.post(name: .ordersBadgeReloadRequired, object: nil)
            onCompletion(true)
        }
    }

    /// Do all the operations to log out from the current selected store, maintaining the Authentication
    ///
    private func logOutOfCurrentStore(onCompletion: @escaping () -> Void) {
        guard stores.sessionManager.defaultStoreID != nil else {
            return onCompletion()
        }

        stores.removeDefaultStore()

        // Note: We are not deleting products here because products from multiple sites
        // can exist in Storage simultaneously. Eventually we should make orders and stats
        // behave this way. See https://github.com/woocommerce/woocommerce-ios/issues/279
        // for more details.
        let group = DispatchGroup()

        group.enter()
        let statsV4Action = StatsActionV4.resetStoredStats {
            group.leave()
        }
        stores.dispatch(statsV4Action)

        group.enter()
        let orderAction = OrderAction.resetStoredOrders {
            group.leave()
        }
        stores.dispatch(orderAction)

        group.enter()
        let reviewAction = ProductReviewAction.resetStoredProductReviews {
            group.leave()
        }
        stores.dispatch(reviewAction)

        group.enter()
        let resetAction = CardPresentPaymentAction.reset

        stores.dispatch(resetAction)

        group.leave()

        group.notify(queue: .main) {
            onCompletion()
        }
    }

    /// Part of the switch store selection. This method will update the new default store selected.
    ///
    private func finalizeStoreSelection(_ storeID: Int64) {
        stores.updateDefaultStore(storeID: storeID)

        // We need to call refreshUserData() here because the user selected
        // their default store and tracks should to know about it.
        ServiceLocator.analytics.refreshUserData()
        ServiceLocator.analytics.track(.sitePickerContinueTapped,
                                  withProperties: ["selected_store_id": stores.sessionManager.defaultStoreID ?? String()])

        AppDelegate.shared.authenticatorWasDismissed()
    }
}
