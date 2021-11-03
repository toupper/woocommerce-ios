import Combine
import UIKit
import Yosemite
import WordPressUI


/// Enum representing the individual tabs
///
enum WooTab {

    /// My Store Tab
    ///
    case myStore

    /// Orders Tab
    ///
    case orders

    /// Products Tab
    ///
    case products

    /// Reviews Tab
    ///
    case reviews
}

extension WooTab {
    /// Initializes a tab with the visible tab index.
    ///
    /// - Parameters:
    ///   - visibleIndex: the index of visible tabs on the tab bar
    init(visibleIndex: Int) {
        let tabs = WooTab.visibleTabs()
        self = tabs[visibleIndex]
    }

    /// Returns the visible tab index.
    func visibleIndex() -> Int {
        let tabs = WooTab.visibleTabs()
        guard let tabIndex = tabs.firstIndex(where: { $0 == self }) else {
            assertionFailure("Trying to get the visible tab index for tab \(self) while the visible tabs are: \(tabs)")
            return 0
        }
        return tabIndex
    }

    // Note: currently only the Dashboard tab (My Store) view controller is set up in Main.storyboard.
    private static func visibleTabs() -> [WooTab] {
            return [.myStore, .orders, .products, .reviews]
    }
}


// MARK: - MainTabBarController

/// A view controller that shows the tabs Store, Orders, Products, and Reviews.
///
/// TODO Migrate the `viewControllers` management from `Main.storyboard` to here (as code).
///
final class MainTabBarController: UITabBarController {

    /// For picking up the child view controller's status bar styling
    /// - returns: nil to let the tab bar control styling or `children.first` for VC control.
    ///
    public override var childForStatusBarStyle: UIViewController? {
        return nil
    }

    /// Used for overriding the status bar style for all child view controllers
    ///
    override var preferredStatusBarStyle: UIStatusBarStyle {
        ServiceLocator.featureFlagService.isFeatureFlagEnabled(.largeTitles) ? .default: StyleManager.statusBarLight
    }

    /// Notifications badge
    ///
    private let notificationsBadge = NotificationsBadgeController()

    /// ViewModel
    ///
    private let viewModel = MainTabViewModel()

    /// Tab view controllers
    ///
    private let dashboardNavigationController = WooTabNavigationController()
    private let ordersNavigationController = WooTabNavigationController()
    private let productsNavigationController = WooTabNavigationController()
    private let reviewsNavigationController = WooTabNavigationController()
    private var reviewsTabCoordinator: ReviewsCoordinator?

    private var cancellableSiteID: AnyCancellable?

    private let stores: StoresManager = ServiceLocator.stores

    deinit {
        cancellableSiteID?.cancel()
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate() // call this to refresh status bar changes happening at runtime

        configureTabViewControllers()
        observeSiteIDForViewControllers()

        loadReviewsTabNotificationCountAndUpdateBadge()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// Note:
        /// We hook up KVO in this spot... because at the point in which `viewDidLoad` fires, we haven't really fully
        /// loaded the childViewControllers, and the tabBar isn't fully initialized.
        ///
        startListeningToReviewsTabBadgeUpdates()
        startListeningToOrdersBadge()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.onViewDidAppear()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentlySelectedTab = WooTab(visibleIndex: selectedIndex)
        guard let userSelectedIndex = tabBar.items?.firstIndex(of: item) else {
                return
        }
        let userSelectedTab = WooTab(visibleIndex: userSelectedIndex)

        // Did we reselect the already-selected tab?
        if currentlySelectedTab == userSelectedTab {
            trackTabReselected(tab: userSelectedTab)
            scrollContentToTop()
        } else {
            trackTabSelected(newTab: userSelectedTab)
        }
    }

    // MARK: - Public Methods

    /// Switches the TabBarcController to the specified Tab
    ///
    func navigateTo(_ tab: WooTab, animated: Bool = false, completion: (() -> Void)? = nil) {
        selectedIndex = tab.visibleIndex()
        if let navController = selectedViewController as? UINavigationController {
            navController.popToRootViewController(animated: animated) {
                completion?()
            }
        }
    }

    /// Removes the view controllers in each tab's navigation controller, and resets any logged in properties.
    /// Called after the app is logged out and authentication UI is presented.
    func removeViewControllers() {
        viewControllers?.compactMap { $0 as? UINavigationController }.forEach { navigationController in
            navigationController.viewControllers = []
        }
        reviewsTabCoordinator = nil
    }
}


// MARK: - UIViewControllerTransitioningDelegate
//
extension MainTabBarController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard presented is FancyAlertViewController || presented is CardPresentPaymentsModalViewController else {
            return nil
        }

        return FancyAlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


// MARK: - Static navigation helpers
//
private extension MainTabBarController {

    /// *When applicable* this method will scroll the visible content to top.
    ///
    func scrollContentToTop() {
        guard let navController = selectedViewController as? UINavigationController else {
            return
        }

        navController.scrollContentToTop(animated: true)
    }

    /// Tracks "Tab Selected" Events.
    ///
    func trackTabSelected(newTab: WooTab) {
        switch newTab {
        case .myStore:
            ServiceLocator.analytics.track(.dashboardSelected)
        case .orders:
            ServiceLocator.analytics.track(.ordersSelected)
        case .products:
            ServiceLocator.analytics.track(.productListSelected)
        case .reviews:
            ServiceLocator.analytics.track(.notificationsSelected)
        }
    }

    /// Tracks "Tab Re Selected" Events.
    ///
    func trackTabReselected(tab: WooTab) {
        switch tab {
        case .myStore:
            ServiceLocator.analytics.track(.dashboardReselected)
        case .orders:
            ServiceLocator.analytics.track(.ordersReselected)
        case .products:
            ServiceLocator.analytics.track(.productListReselected)
        case .reviews:
            ServiceLocator.analytics.track(.notificationsReselected)
        }
    }
}


// MARK: - Static navigation helpers
//
extension MainTabBarController {

    /// Switches to the My Store tab and pops to the root view controller
    ///
    static func switchToMyStoreTab(animated: Bool = false) {
        navigateTo(.myStore, animated: animated)
    }

    /// Switches to the Orders tab and pops to the root view controller
    ///
    static func switchToOrdersTab(completion: (() -> Void)? = nil) {
        navigateTo(.orders, completion: completion)
    }

    /// Switches to the Reviews tab and pops to the root view controller
    ///
    static func switchToReviewsTab(completion: (() -> Void)? = nil) {
        navigateTo(.reviews, completion: completion)
    }

    /// Switches the TabBarController to the specified Tab
    ///
    private static func navigateTo(_ tab: WooTab, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let tabBar = AppDelegate.shared.tabBarController else {
            return
        }

        tabBar.navigateTo(tab, animated: animated, completion: completion)
    }

    /// Returns the "Top Visible Child" of the specified type
    ///
    private static func childViewController<T: UIViewController>() -> T? {
        let selectedViewController = AppDelegate.shared.tabBarController?.selectedViewController
        guard let navController = selectedViewController as? UINavigationController else {
            return selectedViewController as? T
        }

        return navController.topViewController as? T
    }
}


// MARK: - Static Navigation + Details!
//
extension MainTabBarController {

    /// Syncs the notification given the ID, and handles the notification based on its notification kind.
    ///
    static func presentNotificationDetails(for noteID: Int64) {
        let action = NotificationAction.synchronizeNotification(noteID: noteID) { note, error in
            guard let note = note else {
                return
            }
            let siteID = Int64(note.meta.identifier(forKey: .site) ?? Int.min)
            SwitchStoreUseCase(stores: ServiceLocator.stores).switchStore(with: siteID) { siteChanged in
                presentNotificationDetails(for: note)

                if siteChanged {
                    let presenter = SwitchStoreNoticePresenter(siteID: siteID)
                    presenter.presentStoreSwitchedNoticeWhenSiteIsAvailable(configuration: .switchingStores)
                }
            }
        }
        ServiceLocator.stores.dispatch(action)
    }

    /// Presents the order details if the `note` is for an order push notification.
    ///
    /// For Product Review notifications, that is now handled by `ReviewsCoordinator`. This method
    /// should also be moved to a similar `Coordinator` in the future too.
    ///
    private static func presentNotificationDetails(for note: Note) {
        switch note.kind {
        case .storeOrder:
            switchToOrdersTab {
                guard let ordersVC: OrdersRootViewController = childViewController() else {
                    return
                }

                ordersVC.presentDetails(for: note)
            }
        default:
            break
        }

        ServiceLocator.analytics.track(.notificationOpened, withProperties: [ "type": note.kind.rawValue,
                                                                              "already_read": note.read ])
    }

    /// Switches to the My Store Tab, and presents the Settings .
    ///
    static func presentSettings() {
        switchToMyStoreTab(animated: false)

        guard let dashBoard: DashboardViewController = childViewController() else {
            return
        }

        dashBoard.presentSettings()
    }
}

// MARK: - Site ID observation for updating tab view controllers
//
private extension MainTabBarController {
    func configureTabViewControllers() {
        viewControllers = {
            var controllers = [UIViewController]()

            let dashboardTabIndex = WooTab.myStore.visibleIndex()
            controllers.insert(dashboardNavigationController, at: dashboardTabIndex)

            let ordersTabIndex = WooTab.orders.visibleIndex()
            controllers.insert(ordersNavigationController, at: ordersTabIndex)

            let productsTabIndex = WooTab.products.visibleIndex()
            controllers.insert(productsNavigationController, at: productsTabIndex)

            let reviewsTabIndex = WooTab.reviews.visibleIndex()
            controllers.insert(reviewsNavigationController, at: reviewsTabIndex)

            return controllers
        }()
    }

    func observeSiteIDForViewControllers() {
        cancellableSiteID = stores.siteID.sink { [weak self] siteID in
            guard let self = self else {
                return
            }
            self.updateViewControllers(siteID: siteID)
        }
    }

    func updateViewControllers(siteID: Int64?) {
        guard let siteID = siteID else {
            return
        }

        // Update view model with `siteID` to query correct Orders Status
        viewModel.configureOrdersStatusesListener(for: siteID)

        // Initialize each tab's root view controller
        let dashboardViewController = createDashboardViewController(siteID: siteID)
        dashboardNavigationController.viewControllers = [dashboardViewController]

        let ordersViewController = createOrdersViewController(siteID: siteID)
        ordersNavigationController.viewControllers = [ordersViewController]

        let productsViewController = createProductsViewController(siteID: siteID)
        productsNavigationController.viewControllers = [productsViewController]

        // Configure reviews tab coordinator once per logged in session potentially with multiple sites.
        if reviewsTabCoordinator == nil {
            let reviewsTabCoordinator = createReviewsTabCoordinator()
            self.reviewsTabCoordinator = reviewsTabCoordinator
            reviewsTabCoordinator.start()
        }

        reviewsTabCoordinator?.activate(siteID: siteID)

        // Set dashboard to be the default tab.
        selectedIndex = WooTab.myStore.visibleIndex()
    }

    func createDashboardViewController(siteID: Int64) -> UIViewController {
        DashboardViewController(siteID: siteID)
    }

    func createOrdersViewController(siteID: Int64) -> UIViewController {
        OrdersRootViewController(siteID: siteID)
    }

    func createProductsViewController(siteID: Int64) -> UIViewController {
        ProductsViewController(siteID: siteID)
    }

    func createReviewsTabCoordinator() -> ReviewsCoordinator {
        ReviewsCoordinator(navigationController: reviewsNavigationController,
                           willPresentReviewDetailsFromPushNotification: { [weak self] in
                            self?.navigateTo(.reviews)
        })
    }
}

// MARK: - Reviews Tab Badge Updates
//
private extension MainTabBarController {

    /// Setup: KVO Hooks.
    ///
    func startListeningToReviewsTabBadgeUpdates() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadReviewsTabNotificationCountAndUpdateBadge),
                                               name: .reviewsBadgeReloadRequired,
                                               object: nil)
    }

    @objc func loadReviewsTabNotificationCountAndUpdateBadge() {
        guard let siteID = stores.sessionManager.defaultStoreID else {
            return
        }

        let action = NotificationCountAction.load(siteID: siteID, type: .kind(.comment)) { [weak self] count in
            self?.updateReviewsTabBadge(count: count)
        }
        stores.dispatch(action)
    }

    /// Displays or Hides the Dot on the Reviews tab, depending on the notification count
    ///
    func updateReviewsTabBadge(count: Int) {
        let tab = WooTab.reviews
        let tabIndex = tab.visibleIndex()
        notificationsBadge.badgeCountWasUpdated(newValue: count, tab: tab, in: tabBar, tabIndex: tabIndex)
    }
}

// MARK: - Orders Tab Badge

private extension MainTabBarController {
    func startListeningToOrdersBadge() {
        viewModel.onBadgeReload = { [weak self] countReadableString in
            guard let self = self else {
                return
            }

            let tab = WooTab.orders
            let tabIndex = tab.visibleIndex()

            guard let orderTab: UITabBarItem = self.tabBar.items?[tabIndex] else {
                return
            }

            orderTab.badgeValue = countReadableString
            orderTab.badgeColor = .primary
        }

        viewModel.startObservingOrdersCount()
    }
}
