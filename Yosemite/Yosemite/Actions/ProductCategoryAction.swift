import Foundation
import Networking

/// ProductCategoryAction: Defines all of the Actions supported by the ProductCategoryStore.
///
public enum ProductCategoryAction: Action {

    /// Synchronizes all ProductCategories matching the specified criteria.
    /// `onCompletion` will be invoked when the sync operation finishes. `error` will be nill if the operation succeed.
    ///
    case synchronizeProductCategories(siteID: Int64, fromPageNumber: Int, onCompletion: (ProductCategoryActionError?) -> Void)

    /// Create a new product category associated with a given Site ID.
    /// `onCompletion` will be invoked when the add operation finishes. `error` will be nill if the operation succeed.
    ///
    case addProductCategory(siteID: Int64, name: String, parentID: Int64?, onCompletion: (Result<ProductCategory, Error>) -> Void)

    /// Synchronizes the filter product category setting, updating it with the new information if any, or deleting
    /// in case the product category was removed remotely.
    /// `onCompletion` will be invoked when the sync operation finishes. `error` will be nill if the operation succeed.
    ///
    case synchronizeProductCategoryFilterSetting(siteID: Int64, onCompletion: (Error?) -> Void)

}

/// Defines all errors that a `ProductCategoryAction` can return
///
public enum ProductCategoryActionError: Error {
    /// Represents a product category synchronization failed state
    ///
    case categoriesSynchronization(pageNumber: Int, rawError: Error)
}
