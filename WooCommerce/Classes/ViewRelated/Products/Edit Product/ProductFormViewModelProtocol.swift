import Yosemite
import Observables

/// The type of product form: adding a new one or editing an existing one.
enum ProductFormType {
    case add
    case edit
    case readonly
}

/// The type of action that can be performed in the product.
enum ActionButtonType {
    case publish
    case save
    case more
}

/// The type of save message when saving a product.
enum SaveMessageType {
    case publish
    case save
}

/// A view model for `ProductFormViewController` to add/edit a generic product model (e.g. `Product` or `ProductVariation`).
///
protocol ProductFormViewModelProtocol {
    associatedtype ProductModel: ProductFormDataModel & TaxClassRequestable

    /// Emits product on change, except when the product name is the only change (`productName` is emitted for this case).
    var observableProduct: Observable<ProductModel> { get }

    /// The type of form: adding a new product or editing an existing product.
    var formType: ProductFormType { get }

    /// Emits product name on change. If the name is not editable (e.g. when the product model is `ProductVariation`), `nil` is returned.
    var productName: Observable<String>? { get }

    /// Emits a boolean of whether the product has unsaved changes for remote update.
    var isUpdateEnabled: Observable<Bool> { get }

    /// Emits a void value informing when there is a new variation price state available
    var newVariationsPrice: Observable<Void> { get }

    /// Creates actions available on the bottom sheet.
    var actionsFactory: ProductFormActionsFactoryProtocol { get }

    /// The latest product value.
    var productModel: ProductModel { get }

    /// The original product value.
    var originalProductModel: ProductModel { get }

    /// The latest product password, if the product is password protected.
    var password: String? { get }

    /// The action buttons that should be rendered in the navigation bar.
    var actionButtons: [ActionButtonType] { get }

    // Unsaved changes

    func hasUnsavedChanges() -> Bool

    // More menu

    func canSaveAsDraft() -> Bool

    func canShowPublishOption() -> Bool

    func canEditProductSettings() -> Bool

    func canViewProductInStore() -> Bool

    func canShareProduct() -> Bool

    func canDeleteProduct() -> Bool

    // Update actions

    func updateName(_ name: String)

    func updateImages(_ images: [ProductImage])

    func updateDescription(_ newDescription: String)

    func updatePriceSettings(regularPrice: String?,
                             salePrice: String?,
                             dateOnSaleStart: Date?,
                             dateOnSaleEnd: Date?,
                             taxStatus: ProductTaxStatus,
                             taxClass: TaxClass?)

    func updateInventorySettings(sku: String?,
                                 manageStock: Bool,
                                 soldIndividually: Bool?,
                                 stockQuantity: Decimal?,
                                 backordersSetting: ProductBackordersSetting?,
                                 stockStatus: ProductStockStatus?)

    func updateProductType(productType: BottomSheetProductType)

    func updateShippingSettings(weight: String?, dimensions: ProductDimensions, shippingClass: String?, shippingClassID: Int64?)

    func updateProductCategories(_ categories: [ProductCategory])

    func updateProductTags(_ tags: [ProductTag])

    func updateShortDescription(_ shortDescription: String)

    func updateSKU(_ sku: String?)

    func updateGroupedProductIDs(_ groupedProductIDs: [Int64])

    func updateProductSettings(_ settings: ProductSettings)

    func updateExternalLink(externalURL: String?, buttonText: String)

    func updateStatus(_ isEnabled: Bool)

    func updateDownloadableFiles(downloadableFiles: [ProductDownload], downloadLimit: Int64, downloadExpiry: Int64)

    func updateLinkedProducts(upsellIDs: [Int64], crossSellIDs: [Int64])

    func updateVariationAttributes(_ attributes: [ProductVariationAttribute])

    // Remote action

    /// Creates/updates a product remotely given an optional product status to override.
    /// - Parameters:
    ///   - status: If non-nil, the given status overrides the latest product's status to be saved remotely.
    ///   - onCompletion: Called when the product is saved remotely.
    func saveProductRemotely(status: ProductStatus?, onCompletion: @escaping (Result<ProductModel, ProductUpdateError>) -> Void)

    func deleteProductRemotely(onCompletion: @escaping (Result<Void, ProductUpdateError>) -> Void)

    // Reset action

    func resetPassword(_ password: String?)

    /// Updates the original product variations(and attributes).
    /// This is needed because variations and attributes, remote updates, happen outside this view model and we need a way to sync the original product.
    func updateProductVariations(from product: Product)
}

extension ProductFormViewModelProtocol {
    func shouldShowMoreOptionsMenu() -> Bool {
        canSaveAsDraft() || canEditProductSettings() || canViewProductInStore() || canShareProduct() || canDeleteProduct()
    }

    /// Returns `.publish` when the product does not exists remotely and it's gonna be published for the first time.
    /// Returns `.publish` when the product is going to be published from a different status (eg: from draft).
    /// Returns `.save` for any other case.
    ///
    func saveMessageType(for productStatus: ProductStatus) -> SaveMessageType {
        switch productStatus {
        case .publish where !productModel.existsRemotely || originalProductModel.status != .publish:
            return .publish
        default:
            return .save
        }
    }
}
