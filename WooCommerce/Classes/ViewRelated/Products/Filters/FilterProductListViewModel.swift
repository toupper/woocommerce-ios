import UIKit
import Yosemite

/// `FilterListViewModel` for filtering a list of products.
final class FilterProductListViewModel: FilterListViewModel {
    typealias Criteria = Filters

    /// Aggregates the filter values that can be updated in the Filter Products UI.
    struct Filters: Equatable {
        let stockStatus: ProductStockStatus?
        let productStatus: ProductStatus?
        let productType: ProductType?
        let productCategory: ProductCategory?

        let numberOfActiveFilters: Int

        init() {
            stockStatus = nil
            productStatus = nil
            productType = nil
            productCategory = nil
            numberOfActiveFilters = 0
        }

        init(stockStatus: ProductStockStatus?,
             productStatus: ProductStatus?,
             productType: ProductType?,
             productCategory: ProductCategory?,
             numberOfActiveFilters: Int) {
            self.stockStatus = stockStatus
            self.productStatus = productStatus
            self.productType = productType
            self.productCategory = productCategory
            self.numberOfActiveFilters = numberOfActiveFilters
        }

        // Generate a string based on populated filters, like "instock,publish,simple"
        var analyticsDescription: String {
            let elements: [String?] = [stockStatus?.rawValue, productStatus?.rawValue, productType?.rawValue]
            return elements.compactMap { $0 }.joined(separator: ",")
        }
    }

    let filterActionTitle = NSLocalizedString("Show Products", comment: "Button title for applying filters to a list of products.")

    let filterTypeViewModels: [FilterTypeViewModel]

    private let stockStatusFilterViewModel: FilterTypeViewModel
    private let productStatusFilterViewModel: FilterTypeViewModel
    private let productTypeFilterViewModel: FilterTypeViewModel
    private let productCategoryFilterViewModel: FilterTypeViewModel

    /// - Parameters:
    ///   - filters: the filters to be applied initially.
    init(filters: Filters, siteID: Int64) {
        self.stockStatusFilterViewModel = ProductListFilter.stockStatus.createViewModel(filters: filters, siteID: siteID)
        self.productStatusFilterViewModel = ProductListFilter.productStatus.createViewModel(filters: filters, siteID: siteID)
        self.productTypeFilterViewModel = ProductListFilter.productType.createViewModel(filters: filters, siteID: siteID)
        self.productCategoryFilterViewModel = ProductListFilter.productCategory.createViewModel(filters: filters, siteID: siteID)

        var filterTypeViewModels = [
            stockStatusFilterViewModel,
            productStatusFilterViewModel,
            productTypeFilterViewModel
        ]

        if ServiceLocator.featureFlagService.isFeatureFlagEnabled(.filterProductsByCategory) {
            filterTypeViewModels.append(productCategoryFilterViewModel)
        }

        self.filterTypeViewModels = filterTypeViewModels
    }

    var criteria: Filters {
        let stockStatus = stockStatusFilterViewModel.selectedValue as? ProductStockStatus ?? nil
        let productStatus = productStatusFilterViewModel.selectedValue as? ProductStatus ?? nil
        let productType = productTypeFilterViewModel.selectedValue as? ProductType ?? nil
        var productCategory: ProductCategory? = nil

        if ServiceLocator.featureFlagService.isFeatureFlagEnabled(.filterProductsByCategory),
           let selectedProductCategory = productCategoryFilterViewModel.selectedValue as? ProductCategory {
            productCategory = selectedProductCategory
        }

        let numberOfActiveFilters = filterTypeViewModels.numberOfActiveFilters

        return Filters(stockStatus: stockStatus,
                       productStatus: productStatus,
                       productType: productType,
                       productCategory: productCategory,
                       numberOfActiveFilters: numberOfActiveFilters)
    }

    func clearAll() {
        let clearedStockStatus: ProductStockStatus? = nil
        stockStatusFilterViewModel.selectedValue = clearedStockStatus

        let clearedProductStatus: ProductStatus? = nil
        productStatusFilterViewModel.selectedValue = clearedProductStatus

        let clearedProductType: ProductType? = nil
        productTypeFilterViewModel.selectedValue = clearedProductType

        if ServiceLocator.featureFlagService.isFeatureFlagEnabled(.filterProductsByCategory) {
            let clearedProductCategory: ProductCategory? = nil
            productCategoryFilterViewModel.selectedValue = clearedProductCategory
        }
    }
}

extension FilterProductListViewModel {
    /// Rows listed in the order they appear on screen
    ///
    enum ProductListFilter {
        case stockStatus
        case productStatus
        case productType
        case productCategory
    }
}

private extension FilterProductListViewModel.ProductListFilter {
    var title: String {
        switch self {
        case .stockStatus:
            return NSLocalizedString("Stock Status", comment: "Row title for filtering products by stock status.")
        case .productStatus:
            return NSLocalizedString("Product Status", comment: "Row title for filtering products by product status.")
        case .productType:
            return NSLocalizedString("Product Type", comment: "Row title for filtering products by product type.")
        case .productCategory:
            return NSLocalizedString("Product Category", comment: "Row title for filtering products by product category.")
        }
    }
}

extension FilterProductListViewModel.ProductListFilter {
    func createViewModel(filters: FilterProductListViewModel.Filters, siteID: Int64) -> FilterTypeViewModel {
        switch self {
        case .stockStatus:
            let options: [ProductStockStatus?] = [nil, .inStock, .outOfStock, .onBackOrder]
            return FilterTypeViewModel(title: title,
                                       listSelectorConfig: .staticOptions(options: options),
                                       selectedValue: filters.stockStatus)
        case .productStatus:
            let options: [ProductStatus?] = [nil, .publish, .draft, .pending]
            return FilterTypeViewModel(title: title,
                                       listSelectorConfig: .staticOptions(options: options),
                                       selectedValue: filters.productStatus)
        case .productType:
            let options: [ProductType?] = [nil, .simple, .variable, .grouped, .affiliate]
            return FilterTypeViewModel(title: title,
                                       listSelectorConfig: .staticOptions(options: options),
                                       selectedValue: filters.productType)
        case .productCategory:
            return FilterTypeViewModel(title: title,
                                       listSelectorConfig: .categories(siteID: siteID),
                                       selectedValue: filters.productCategory)
        }
    }
}
