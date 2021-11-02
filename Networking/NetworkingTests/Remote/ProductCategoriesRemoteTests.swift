import XCTest
@testable import Networking

/// ProductCategoriesRemoteTests
///
final class ProductCategoriesRemoteTests: XCTestCase {

    /// Dummy Network Wrapper
    ///
    private var network: MockNetwork!

    /// Dummy Site ID
    ///
    private let sampleSiteID: Int64 = 1234

    override func setUp() {
        super.setUp()
        network = MockNetwork()
    }

    override func tearDown() {
        network = nil
        super.tearDown()
    }

    // MARK: - Load all product categories tests

    /// Verifies that loadAllProductCategories properly parses the `categories-all` sample response.
    ///
    func testLoadAllProductCategoriesProperlyReturnsParsedProductCategories() {
        // Given
        let remote = ProductCategoriesRemote(network: network)
        let expectation = self.expectation(description: "Load All Product Categories")

        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "categories-all")

        // When
        var result: (categories: [ProductCategory]?, error: Error?)
        remote.loadAllProductCategories(for: sampleSiteID) { categories, error in
            result = (categories, error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Constants.expectationTimeout)

        // Then
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.categories)
        XCTAssertEqual(result.categories?.count, 2)
    }

    /// Verifies that loadAllProductCategories properly relays Networking Layer errors.
    ///
    func testLoadAllProductCategoriesProperlyRelaysNetwokingErrors() {
        // Given
        let remote = ProductCategoriesRemote(network: network)
        let expectation = self.expectation(description: "Load All Product Categories returns error")

        // When
        var result: (categories: [ProductCategory]?, error: Error?)
        remote.loadAllProductCategories(for: sampleSiteID) { categories, error in
            result = (categories, error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Constants.expectationTimeout)

        // Then
        XCTAssertNil(result.categories)
        XCTAssertNotNil(result.error)
    }

    // MARK: - Create a product category tests

    /// Verifies that createProductCategory properly parses the `category` sample response.
    ///
    func testCreateProductCategoryProperlyReturnsParsedProductCategory() {
        // Given
        let remote = ProductCategoriesRemote(network: network)

        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "category")

        // When
        var result: Result<ProductCategory, Error>?
        waitForExpectation { exp in
            remote.createProductCategory(for: sampleSiteID, name: "Dress", parentID: 0) { aResult in
                result = aResult
                exp.fulfill()
            }
        }

        // Then
        XCTAssertNil(result?.failure)
        XCTAssertNotNil(try result?.get())
        XCTAssertEqual(try result?.get().name, "Dress")
    }

    func test_loadProductCategory_then_returns_parsed_ProductCategory() {
        // Given
        let remote = ProductCategoriesRemote(network: network)
        let categoryID: Int64 = 44

        network.simulateResponse(requestUrlSuffix: "products/categories/\(categoryID)", filename: "category")

        let result: Result<ProductCategory, Error>? = waitFor { [weak self] promise in
            guard let self = self else {
                return
            }

            remote.loadProductCategory(with: categoryID, siteID: self.sampleSiteID) {  aResult in
                promise(aResult)
            }
        }

        // Then
        XCTAssertNil(result?.failure)
        XCTAssertNotNil(try result?.get())
        XCTAssertEqual(try result?.get().name, "Dress")
    }

    func test_loadProductCategory_network_fails_then_returns_error() {
        // Given
        let remote = ProductCategoriesRemote(network: network)
        let categoryID: Int64 = 44

        let result: Result<ProductCategory, Error>? = waitFor { [weak self] promise in
            guard let self = self else {
                return
            }

            remote.loadProductCategory(with: categoryID, siteID: self.sampleSiteID) {  aResult in
                promise(aResult)
            }
        }

        // Then
        XCTAssertNil(try? result?.get())
        XCTAssertNotNil(result?.failure)
    }

    /// Verifies that createProductCategory properly relays Networking Layer errors.
    ///
    func testCreateProductCategoryProperlyRelaysNetwokingErrors() {
        // Given
        let remote = ProductCategoriesRemote(network: network)
        let expectation = self.expectation(description: "Create Product Category returns error")

        // When
        var result: Result<ProductCategory, Error>?
        remote.createProductCategory(for: sampleSiteID, name: "Dress", parentID: 0) { aResult in
            result = aResult
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Constants.expectationTimeout)

        // Then
        XCTAssertNil(try? result?.get())
        XCTAssertNotNil(result?.failure)
    }

}
