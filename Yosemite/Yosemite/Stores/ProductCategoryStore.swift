import Foundation
import Networking
import Storage

// MARK: - ProductCategoryStore
//
public final class ProductCategoryStore: Store {
    private let remote: ProductCategoriesRemote

    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = ProductCategoriesRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: ProductCategoryAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? ProductCategoryAction else {
            assertionFailure("ProductCategoryStore received an unsupported action")
            return
        }

        switch action {
        case let .synchronizeProductCategories(siteID, fromPageNumber, onCompletion):
            synchronizeAllProductCategories(siteID: siteID, fromPageNumber: fromPageNumber, onCompletion: onCompletion)
        case .addProductCategory(siteID: let siteID, name: let name, parentID: let parentID, onCompletion: let onCompletion):
            addProductCategory(siteID: siteID, name: name, parentID: parentID, onCompletion: onCompletion)
        case .synchronizeProductCategoryFilterSetting(siteID: let siteID, onCompletion: let onCompletion):
            synchronizeProductCategoryFilterSetting(siteID: siteID, onCompletion: onCompletion)
        }
    }
}

// MARK: - Services
//
private extension ProductCategoryStore {

    /// Synchronizes all product categories associated with a given Site ID, starting at a specific page number.
    ///
    func synchronizeAllProductCategories(siteID: Int64, fromPageNumber: Int, onCompletion: @escaping (ProductCategoryActionError?) -> Void) {
        // Start fetching the provided initial page
        synchronizeProductCategories(siteID: siteID, pageNumber: fromPageNumber, pageSize: Constants.defaultMaxPageSize) { [weak self] categories, error in
            guard let self = self  else {
                return
            }

            // If there is an error, end the recursion and call `onCompletion` with an `error`
            if let error = error {
                let synchronizationError = ProductCategoryActionError.categoriesSynchronization(pageNumber: fromPageNumber, rawError: error)
                onCompletion(synchronizationError)
                return
            }

            // If categories is nil, end the recursion and call `onCompletion`
            if categories == nil {
                onCompletion(nil)
                return
            }

            // If categories is empty, end the recursion and call `onCompletion`
            if let categories = categories, categories.isEmpty {
                onCompletion(nil)
                return
            }

            // Request the next page recursively
            self.synchronizeAllProductCategories(siteID: siteID, fromPageNumber: fromPageNumber + 1, onCompletion: onCompletion)
        }
    }

    /// Synchronizes product categories associated with a given Site ID.
    ///
    func synchronizeProductCategories(siteID: Int64, pageNumber: Int, pageSize: Int, onCompletion: @escaping ([ProductCategory]?, Error?) -> Void) {
        remote.loadAllProductCategories(for: siteID, pageNumber: pageNumber, pageSize: pageSize) { [weak self] (productCategories, error) in
            guard let productCategories = productCategories else {
                onCompletion(nil, error)
                return
            }

            if pageNumber == Default.firstPageNumber {
                self?.deleteUnusedStoredProductCategories(siteID: siteID)
            }

            self?.upsertStoredProductCategoriesInBackground(productCategories, siteID: siteID) {
                onCompletion(productCategories, nil)
            }
        }
    }

    /// Create a new product category associated with a given Site ID.
    ///
    func addProductCategory(siteID: Int64, name: String, parentID: Int64?, onCompletion: @escaping (Result<ProductCategory, Error>) -> Void) {
        remote.createProductCategory(for: siteID, name: name, parentID: parentID) { [weak self] result in
            switch result {
            case .success(let productCategory):
                self?.upsertStoredProductCategoriesInBackground([productCategory], siteID: siteID) {
                    onCompletion(.success(productCategory))
                }
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }

    /// Deletes any Storage.ProductCategory  that is not associated to a product on the specified `siteID`
    ///
    func deleteUnusedStoredProductCategories(siteID: Int64) {
        let storage = storageManager.viewStorage
        storage.deleteUnusedProductCategories(siteID: siteID)
        storage.saveIfNeeded()
    }
}

// MARK: - Storage: ProductCategory
//
private extension ProductCategoryStore {
    /// Updates (OR Inserts) the specified ReadOnly ProductCategory Entities *in a background thread*.
    /// onCompletion will be called on the main thread!
    ///
    func upsertStoredProductCategoriesInBackground(_ readOnlyProductCategories: [Networking.ProductCategory],
                                                   siteID: Int64,
                                                   onCompletion: @escaping () -> Void) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform { [weak self] in
            self?.upsertStoredProductCategories(readOnlyProductCategories, in: derivedStorage, siteID: siteID)
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }

    /// Checks whether there is a ProductCategory stored to filter a list of products.
    /// If there is one, checks whether that property exists remotely, updating it locally
    /// with the new information, of deleting it if the ProductCategory does not exist remotely anymore
    ///
    func synchronizeProductCategoryFilterSetting(siteID: Int64, onCompletion: @escaping (Error?) -> Void) {
        let loadAction = AppSettingsAction.loadProductsSettings(siteID: siteID) { [weak self] (result) in
            switch result {
            case .success(let settings):
                self?.synchronizeProductCategoryFilter(from: settings, onCompletion: onCompletion)
            case .failure(let error):
                onCompletion(error)
            }
        }

        dispatcher.dispatch(loadAction)
    }
}

private extension ProductCategoryStore {
    /// Updates (OR Inserts) the specified ReadOnly ProductCategory entities into the Storage Layer.
    ///
    /// - Parameters:
    ///     - readOnlyProducCategories: Remote ProductCategories to be persisted.
    ///     - storage: Where we should save all the things!
    ///     - siteID: site ID for looking up the ProductCategory.
    ///
    func upsertStoredProductCategories(_ readOnlyProductCategories: [Networking.ProductCategory],
                                       in storage: StorageType,
                                       siteID: Int64) {
        // Upserts the ProductCategory models from the read-only version
        for readOnlyProductCategory in readOnlyProductCategories {
            let storageProductCategory: Storage.ProductCategory = {
                if let storedCategory = storage.loadProductCategory(siteID: siteID, categoryID: readOnlyProductCategory.categoryID) {
                    return storedCategory
                }
                return storage.insertNewObject(ofType: Storage.ProductCategory.self)
            }()
            storageProductCategory.update(with: readOnlyProductCategory)
        }
    }

    /// Updates (OR Removes) the filter ProductCategory in StoredProductSettings according to the remote value
    ///
    /// - Parameters:
    ///     - settings: Settings containing the filter ProductCategory
    ///     - onCompletion: Closure to be executed once the operation is finished
    ///
    func synchronizeProductCategoryFilter(from settings: StoredProductSettings.Setting, onCompletion: @escaping (Error?) -> Void) {
        guard let productCategoryFilter = settings.productCategoryFilter else {
            onCompletion(nil)
            return
        }

        remote.loadProductCategory(with: productCategoryFilter.categoryID,
                                   siteID: productCategoryFilter.siteID) { [weak self] result in
            var updatingProductCategory: ProductCategory? = productCategoryFilter
            switch result {
            case .success(let productCategory):
                updatingProductCategory = productCategory
            case .failure(let error):
                if let error = error as? DotcomError,
                   case .resourceDoesNotExist = error {
                    // The product category was removed, let's do the same locally
                    updatingProductCategory = nil
                }
            }

            if updatingProductCategory != productCategoryFilter {
                let updateAction = AppSettingsAction.upsertProductsSettings(siteID: productCategoryFilter.siteID,
                                                                            sort: settings.sort,
                                                                            stockStatusFilter: settings.stockStatusFilter,
                                                                            productStatusFilter: settings.productStatusFilter,
                                                                            productTypeFilter: settings.productTypeFilter,
                                                                            productCategoryFilter: updatingProductCategory) { (error) in
                    onCompletion(error)
                      }

                self?.dispatcher.dispatch(updateAction)
            } else {
                onCompletion(nil)
            }
        }
    }
}

// MARK: - Constant
//
private extension ProductCategoryStore {
    enum Constants {
        /// Max number allwed by the API to maximize our changces on getting all item in one request.
        ///
        static let defaultMaxPageSize = 100
    }
}
