import Foundation


/// WooCommerce Constants
///
enum WooConstants {

    /// CoreData Stack Name
    ///
    static let databaseStackName = "WooCommerce"

    /// Keychain Access's Service Name
    ///
    static let keychainServiceName = "com.automattic.woocommerce"

    /// Keychain Access's Key for Apple ID
    ///
    static let keychainAppleIDKey = "AppleID"

    /// Push Notifications ApplicationID
    ///
#if DEBUG
    static let pushApplicationID = "com.automattic.woocommerce:dev"
#else
    static let pushApplicationID = "com.automattic.woocommerce"
#endif

    /// Number of section events required before an app review prompt appears
    ///
    static let notificationEventCount = 5

    /// Number of system-wide significant events required
    /// before an app review prompt appears
    ///
    static let systemEventCount = 10
}

// MARK: URLs
//
extension WooConstants {

    /// List of trusted URLs
    ///
    enum URLs: String, CaseIterable {

        /// Terms of Service Website. Displayed by the Authenticator (when / if needed).
        ///
        case termsOfService = "https://wordpress.com/tos/"

        /// Cookie policy URL
        ///
        case cookie = "https://automattic.com/cookies/"

        /// Privacy policy URL
        ///
        case privacy = "https://automattic.com/privacy/"

        /// Privacy policy for California users URL
        ///
        case californiaPrivacy = "https://automattic.com/privacy/#california-consumer-privacy-act-ccpa"

        /// Help Center URL
        ///
        case helpCenter = "https://docs.woocommerce.com/document/woocommerce-ios/"

        /// URL used for Learn More button in Orders empty state.
        ///
        case blog = "https://woocommerce.com/blog/"

        /// Jetpack Setup URL when there are no stores available
        ///
        case emptyStoresJetpackSetup = "https://docs.woocommerce.com/document/jetpack-setup-instructions-for-the-woocommerce-mobile-app/"

        /// URL for in-app feedback survey
        ///
#if DEBUG
        case inAppFeedback = "https://automattic.survey.fm/woo-app-general-feedback-test-survey"
#else
        case inAppFeedback = "https://automattic.survey.fm/woo-app-general-feedback-user-survey"
#endif

        /// URL for the products feedback survey
        ///
        case productsFeedback = "https://automattic.survey.fm/woo-app-feature-feedback-products"

        /// URL for the shipping labels M3 feedback survey
        ///
#if DEBUG
        case shippingLabelsRelease3Feedback = "https://automattic.survey.fm/woo-app-testing-feature-feedback-shipping-labels"
#else
        case shippingLabelsRelease3Feedback = "https://automattic.survey.fm/woo-app-feature-feedback-shipping-labels"
#endif

        /// URL for the order add-on i1 feedback survey
        ///
#if DEBUG
        case orderAddOnI1Feedback = "https://automattic.survey.fm/woo-app-addons-testing"
#else
        case orderAddOnI1Feedback = "https://automattic.survey.fm/woo-app-addons-production"
#endif

        /// URL for shipping label creation information
        ///
        case shippingLabelCreationInfo = "https://woocommerce.com/products/shipping"

        /// URL for product review information
        ///
        case productReviewInfo = "https://woocommerce.com/posts/reviews-woocommerce-best-practices/"

        /// URL for troubleshooting documentation used in Error Loading Data banner
        ///
        case troubleshootErrorLoadingData = "https://docs.woocommerce.com/document/android-ios-apps-troubleshooting-error-fetching-orders/"

        /// URL for roles and permissions information
        ///
        case rolesAndPermissionsInfo = "https://woocommerce.com/posts/a-guide-to-woocommerce-user-roles-permissions-and-security/"

        /// URL for making the login on WordPress.com
        ///
        case loginWPCom = "https://wordpress.com/wp-login.php"

        /// URL for adding a payment method in WCShip extension
        ///
        case addPaymentMethodWCShip = "https://wordpress.com/me/purchases/add-payment-method"

#if DEBUG
        case quickOrderPrototypeFeedback = "https://automattic.survey.fm/woo-app-quick-order-testing"
#else
        case quickOrderPrototypeFeedback = "https://automattic.survey.fm/woo-app-quick-order-production"
#endif

        /// Returns the URL version of the receiver
        ///
        func asURL() -> URL {
            Self.trustedURL(self.rawValue)
        }
    }
}

// MARK: - Utils

private extension WooConstants.URLs {
    /// Convert a `string` to a `URL`. Crash if it is malformed.
    ///
    private static func trustedURL(_ url: String) -> URL {
        if let url = URL(string: url) {
            return url
        } else {
            fatalError("Expected URL \(url) to be a well-formed URL.")
        }
    }
}
