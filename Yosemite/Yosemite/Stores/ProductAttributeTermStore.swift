import Foundation
import Networking
import Storage

public final class ProductAttributeTermStore: Store {
    private let remote: ProductAttributeTermRemote

    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.newDerivedStorage()
    }()

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = ProductAttributeTermRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: ProductAttributeTermAction.self)
    }

    override public func onAction(_ action: Action) {
        guard let action = action as? ProductAttributeTermAction else {
            assertionFailure("ProductAttributeTermStore received an unsupported action")
            return
        }

        switch action {
        case let .synchronizeProductAttributeTerms(siteID, attributeID, onCompletion):
            synchronizeAllProductAttributeTerms(siteID: siteID, attributeID: attributeID, fromPageNumber: 0) { error in
                let result: Result<Void, ProductAttributeTermActionError> = {
                    if let error = error {
                        return .failure(error)
                    }
                    return .success(())
                }()
                onCompletion(result)
            }
        }
    }
}

// MARK: - Services
private extension ProductAttributeTermStore {

    /// Synchronizes all product attribute terms associated with a given `SiteID` and `attributeID`, starting at a specific page number.
    /// Having the correct parent `ProductAttribute` is a requirement, otherwise nothing will be saved.
    ///
    func synchronizeAllProductAttributeTerms(siteID: Int64,
                                             attributeID: Int64,
                                             synchronizedTerms: [Yosemite.ProductAttributeTerm] = [],
                                             fromPageNumber: Int,
                                             onCompletion: @escaping (ProductAttributeTermActionError?) -> Void) {
        // Start fetching the initial page
        synchronizeProductAttributeTerms(siteID: siteID,
                                         attributeID: attributeID,
                                         pageNumber: fromPageNumber,
                                         pageSize: Constants.defaultMaxPageSize) { [weak self] result in
            guard let self = self else { return }
            switch result {

            // If terms is empty, end the recursion and call `onCompletion`
            case let .success(terms) where terms.isEmpty:
                self.deleteStaleTerms(siteID: siteID, attributeID: attributeID, activeTerms: synchronizedTerms)
                onCompletion(nil)

            // If there could be more(non-empty) terms, request the next page recursively.
            case let .success(terms):
                self.synchronizeAllProductAttributeTerms(siteID: siteID,
                                                         attributeID: attributeID,
                                                         synchronizedTerms: synchronizedTerms + terms,
                                                         fromPageNumber: fromPageNumber + 1,
                                                         onCompletion: onCompletion)

            // If there is an error, end the recursion and call `onCompletion`
            case let .failure(error):
                onCompletion(error)
            }
        }
    }

    /// Synchronizes product attribute terms associated with a given `Site ID` ad ` attribute ID` at a specific page.
    ///
    func synchronizeProductAttributeTerms(siteID: Int64,
                                          attributeID: Int64,
                                          pageNumber: Int,
                                          pageSize: Int,
                                          onCompletion: @escaping (Result<[ProductAttributeTerm], ProductAttributeTermActionError>) -> Void) {
        remote.loadProductAttributeTerms(for: siteID, attributeID: attributeID, pageNumber: pageNumber, pageSize: pageSize) { [weak self] terms, error in
            guard let terms = terms else {
                let error = ProductAttributeTermActionError.termsSynchronization(pageNumber: pageNumber, rawError: error)
                return onCompletion(.failure(error))
            }

            self?.upsertStoredProductAttributeTermsInBackground(terms, siteID: siteID, attributeID: attributeID) {
                onCompletion(.success(terms))
            }
        }
    }
}

// MARK: - Storage
//
private extension ProductAttributeTermStore {
    /// Updates (OR Inserts) the specified ReadOnly ProductAttributeTerm Entities *in a background thread*.
    /// onCompletion will be called on the main thread!
    ///
    func upsertStoredProductAttributeTermsInBackground(_ readOnlyTerms: [Networking.ProductAttributeTerm],
                                                       siteID: Int64,
                                                       attributeID: Int64,
                                                       onCompletion: @escaping () -> Void) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform { [weak self] in
            self?.upsertStoredProductAttributeTerms(readOnlyTerms, in: derivedStorage, siteID: siteID, attributeID: attributeID)
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }

    /// Updates (OR Inserts) the specified ReadOnly `ProductAttributeTerm` entities into the Storage Layer.
    /// Having the correct parent `ProductAttribute` is a requirement, otherwise nothing will be saved.
    ///
    func upsertStoredProductAttributeTerms(_ readOnlyTerms: [Networking.ProductAttributeTerm],
                                           in storage: StorageType,
                                           siteID: Int64,
                                           attributeID: Int64) {
        guard let attribute = storage.loadProductAttribute(siteID: siteID, attributeID: attributeID) else {
            return
        }

        // Upserts the ProductAttributeTerm models from the read-only version
        readOnlyTerms.forEach { term in
            let storedTerm: Storage.ProductAttributeTerm = {
                guard let storedTerm = storage.loadProductAttributeTerm(siteID: siteID, termID: term.termID, attributeID: attributeID) else {
                    return storage.insertNewObject(ofType: Storage.ProductAttributeTerm.self)
                }
                return storedTerm
            }()
            storedTerm.update(with: term)
            storedTerm.attribute = attribute
        }
    }

    /// Deletes previously stored terms that where not retrieved during the synchronization.
    ///
    func deleteStaleTerms(siteID: Int64, attributeID: Int64, activeTerms: [Yosemite.ProductAttributeTerm]) {
        let storage = storageManager.viewStorage
        guard let attribute = storage.loadProductAttribute(siteID: siteID, attributeID: attributeID),
              let previousTerms = attribute.terms else {
            return
        }

        // Filter `previousTerms` that are not in `activeTerms`
        let staleTerms = previousTerms.filter { previousTerm -> Bool in
            !activeTerms.contains(where: { $0.termID == previousTerm.termID })
        }

        // Delete stale terms
        staleTerms.forEach { staleTerm in
            storage.deleteObject(staleTerm)
        }
        storage.saveIfNeeded()
    }
}

// MARK: - Constant
//
private extension ProductAttributeTermStore {
    enum Constants {
        /// Max number allowed by the API to maximize our chances on getting all item in one request.
        ///
        static let defaultMaxPageSize = 100
    }
}
