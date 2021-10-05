import XCTest

public final class TabNavComponent: BaseScreen {

    struct ElementStringIDs {
        static let myStoreTabBarItem = "tab-bar-my-store-item"
        static let ordersTabBarItem = "tab-bar-orders-item"
        static let reviewsTabBarItem = "tab-bar-reviews-item"
        static let productsTabBarItem = "tab-bar-products-item"
    }


    private let myStoreTabButton: XCUIElement
    private let ordersTabButton: XCUIElement
    private let reviewsTabButton: XCUIElement
    let productsTabButton: XCUIElement

    init() {
        let tabBar = XCUIApplication().tabBars.firstMatch

        myStoreTabButton = tabBar.buttons[ElementStringIDs.myStoreTabBarItem]
        ordersTabButton = tabBar.buttons[ElementStringIDs.ordersTabBarItem]
        reviewsTabButton = tabBar.buttons[ElementStringIDs.reviewsTabBarItem]
        productsTabButton = tabBar.buttons[ElementStringIDs.productsTabBarItem]

        super.init(element: myStoreTabButton)

        XCTAssert(myStoreTabButton.waitForExistence(timeout: 3))
        XCTAssert(ordersTabButton.waitForExistence(timeout: 3))
    }

    @discardableResult
    func gotoMyStoreScreen() throws -> MyStoreScreen {
        // Avoid transitioning if it is already on screen
        if !MyStoreScreen.isVisible {
            myStoreTabButton.tap()
        }
        return try MyStoreScreen()
    }

    @discardableResult
    public func gotoOrdersScreen() throws -> OrdersScreen {
        // Avoid transitioning if it is already on screen
        if !OrdersScreen.isVisible {
            ordersTabButton.tap()
        }

        return try OrdersScreen()
    }

    @discardableResult
    public func gotoProductsScreen() -> ProductsScreen {
        if !ProductsScreen.isVisible {
            productsTabButton.tap()
        }

        return ProductsScreen()
    }

    @discardableResult
    public func gotoReviewsScreen() throws -> ReviewsScreen {
        if !ReviewsScreen.isVisible {
            reviewsTabButton.tap()
        }

        return try ReviewsScreen()
    }

    static func isLoaded() -> Bool {
        return XCUIApplication().buttons[ElementStringIDs.myStoreTabBarItem].exists
    }

    static func isVisible() -> Bool {
        return XCUIApplication().buttons[ElementStringIDs.myStoreTabBarItem].isHittable
    }
}
