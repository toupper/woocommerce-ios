import Foundation

public protocol ProductUpdater {
    func nameUpdated(name: String) -> Product
    func descriptionUpdated(description: String) -> Product
    func shippingSettingsUpdated(weight: String?, dimensions: ProductDimensions, shippingClass: ProductShippingClass?) -> Product
    func priceSettingsUpdated(regularPrice: String?,
                              salePrice: String?,
                              dateOnSaleStart: Date?,
                              dateOnSaleEnd: Date?,
                              taxStatus: ProductTaxStatus,
                              taxClass: TaxClass?) -> Product
    func inventorySettingsUpdated(sku: String?,
                                  manageStock: Bool,
                                  soldIndividually: Bool,
                                  stockQuantity: Int?,
                                  backordersSetting: ProductBackordersSetting?,
                                  stockStatus: ProductStockStatus?) -> Product
    func imagesUpdated(images: [ProductImage]) -> Product
}

extension Product: ProductUpdater {
    public func nameUpdated(name: String) -> Product {
        return Product(siteID: siteID,
                       productID: productID,
                       name: name,
                       slug: slug,
                       permalink: permalink,
                       dateCreated: dateCreated,
                       dateModified: dateModified,
                       dateOnSaleStart: dateOnSaleStart,
                       dateOnSaleEnd: dateOnSaleEnd,
                       productTypeKey: productTypeKey,
                       statusKey: statusKey,
                       featured: featured,
                       catalogVisibilityKey: catalogVisibilityKey,
                       fullDescription: fullDescription,
                       briefDescription: briefDescription,
                       sku: sku,
                       price: price,
                       regularPrice: regularPrice,
                       salePrice: salePrice,
                       onSale: onSale,
                       purchasable: purchasable,
                       totalSales: totalSales,
                       virtual: virtual,
                       downloadable: downloadable,
                       downloads: downloads,
                       downloadLimit: downloadLimit,
                       downloadExpiry: downloadExpiry,
                       externalURL: externalURL,
                       taxStatusKey: taxStatusKey,
                       taxClass: taxClass,
                       manageStock: manageStock,
                       stockQuantity: stockQuantity,
                       stockStatusKey: stockStatusKey,
                       backordersKey: backordersKey,
                       backordersAllowed: backordersAllowed,
                       backordered: backordered,
                       soldIndividually: soldIndividually,
                       weight: weight,
                       dimensions: dimensions,
                       shippingRequired: shippingRequired,
                       shippingTaxable: shippingTaxable,
                       shippingClass: shippingClass,
                       shippingClassID: shippingClassID,
                       productShippingClass: productShippingClass,
                       reviewsAllowed: reviewsAllowed,
                       averageRating: averageRating,
                       ratingCount: ratingCount,
                       relatedIDs: relatedIDs,
                       upsellIDs: upsellIDs,
                       crossSellIDs: crossSellIDs,
                       parentID: parentID,
                       purchaseNote: purchaseNote,
                       categories: categories,
                       tags: tags,
                       images: images,
                       attributes: attributes,
                       defaultAttributes: defaultAttributes,
                       variations: variations,
                       groupedProducts: groupedProducts,
                       menuOrder: menuOrder)
    }

    public func descriptionUpdated(description: String) -> Product {
        return Product(siteID: siteID,
                       productID: productID,
                       name: name,
                       slug: slug,
                       permalink: permalink,
                       dateCreated: dateCreated,
                       dateModified: dateModified,
                       dateOnSaleStart: dateOnSaleStart,
                       dateOnSaleEnd: dateOnSaleEnd,
                       productTypeKey: productTypeKey,
                       statusKey: statusKey,
                       featured: featured,
                       catalogVisibilityKey: catalogVisibilityKey,
                       fullDescription: description,
                       briefDescription: briefDescription,
                       sku: sku,
                       price: price,
                       regularPrice: regularPrice,
                       salePrice: salePrice,
                       onSale: onSale,
                       purchasable: purchasable,
                       totalSales: totalSales,
                       virtual: virtual,
                       downloadable: downloadable,
                       downloads: downloads,
                       downloadLimit: downloadLimit,
                       downloadExpiry: downloadExpiry,
                       externalURL: externalURL,
                       taxStatusKey: taxStatusKey,
                       taxClass: taxClass,
                       manageStock: manageStock,
                       stockQuantity: stockQuantity,
                       stockStatusKey: stockStatusKey,
                       backordersKey: backordersKey,
                       backordersAllowed: backordersAllowed,
                       backordered: backordered,
                       soldIndividually: soldIndividually,
                       weight: weight,
                       dimensions: dimensions,
                       shippingRequired: shippingRequired,
                       shippingTaxable: shippingTaxable,
                       shippingClass: shippingClass,
                       shippingClassID: shippingClassID,
                       productShippingClass: productShippingClass,
                       reviewsAllowed: reviewsAllowed,
                       averageRating: averageRating,
                       ratingCount: ratingCount,
                       relatedIDs: relatedIDs,
                       upsellIDs: upsellIDs,
                       crossSellIDs: crossSellIDs,
                       parentID: parentID,
                       purchaseNote: purchaseNote,
                       categories: categories,
                       tags: tags,
                       images: images,
                       attributes: attributes,
                       defaultAttributes: defaultAttributes,
                       variations: variations,
                       groupedProducts: groupedProducts,
                       menuOrder: menuOrder)
    }

    public func shippingSettingsUpdated(weight: String?, dimensions: ProductDimensions, shippingClass: ProductShippingClass?) -> Product {
        return Product(siteID: siteID,
                       productID: productID,
                       name: name,
                       slug: slug,
                       permalink: permalink,
                       dateCreated: dateCreated,
                       dateModified: dateModified,
                       dateOnSaleStart: dateOnSaleStart,
                       dateOnSaleEnd: dateOnSaleEnd,
                       productTypeKey: productTypeKey,
                       statusKey: statusKey,
                       featured: featured,
                       catalogVisibilityKey: catalogVisibilityKey,
                       fullDescription: fullDescription,
                       briefDescription: briefDescription,
                       sku: sku,
                       price: price,
                       regularPrice: regularPrice,
                       salePrice: salePrice,
                       onSale: onSale,
                       purchasable: purchasable,
                       totalSales: totalSales,
                       virtual: virtual,
                       downloadable: downloadable,
                       downloads: downloads,
                       downloadLimit: downloadLimit,
                       downloadExpiry: downloadExpiry,
                       externalURL: externalURL,
                       taxStatusKey: taxStatusKey,
                       taxClass: taxClass,
                       manageStock: manageStock,
                       stockQuantity: stockQuantity,
                       stockStatusKey: stockStatusKey,
                       backordersKey: backordersKey,
                       backordersAllowed: backordersAllowed,
                       backordered: backordered,
                       soldIndividually: soldIndividually,
                       weight: weight,
                       dimensions: dimensions,
                       shippingRequired: shippingRequired,
                       shippingTaxable: shippingTaxable,
                       shippingClass: shippingClass?.slug,
                       shippingClassID: shippingClass?.shippingClassID ?? 0,
                       productShippingClass: shippingClass,
                       reviewsAllowed: reviewsAllowed,
                       averageRating: averageRating,
                       ratingCount: ratingCount,
                       relatedIDs: relatedIDs,
                       upsellIDs: upsellIDs,
                       crossSellIDs: crossSellIDs,
                       parentID: parentID,
                       purchaseNote: purchaseNote,
                       categories: categories,
                       tags: tags,
                       images: images,
                       attributes: attributes,
                       defaultAttributes: defaultAttributes,
                       variations: variations,
                       groupedProducts: groupedProducts,
                       menuOrder: menuOrder)
    }

    public func priceSettingsUpdated(regularPrice: String?,
                                     salePrice: String?,
                                     dateOnSaleStart: Date?,
                                     dateOnSaleEnd: Date?,
                                     taxStatus: ProductTaxStatus,
                                     taxClass: TaxClass?) -> Product {
        return Product(siteID: siteID,
        productID: productID,
        name: name,
        slug: slug,
        permalink: permalink,
        dateCreated: dateCreated,
        dateModified: dateModified,
        dateOnSaleStart: dateOnSaleStart,
        dateOnSaleEnd: dateOnSaleEnd,
        productTypeKey: productTypeKey,
        statusKey: statusKey,
        featured: featured,
        catalogVisibilityKey: catalogVisibilityKey,
        fullDescription: fullDescription,
        briefDescription: briefDescription,
        sku: sku,
        price: price,
        regularPrice: regularPrice,
        salePrice: salePrice,
        onSale: onSale,
        purchasable: purchasable,
        totalSales: totalSales,
        virtual: virtual,
        downloadable: downloadable,
        downloads: downloads,
        downloadLimit: downloadLimit,
        downloadExpiry: downloadExpiry,
        externalURL: externalURL,
        taxStatusKey: taxStatus.rawValue,
        taxClass: taxClass?.slug,
        manageStock: manageStock,
        stockQuantity: stockQuantity,
        stockStatusKey: stockStatusKey,
        backordersKey: backordersKey,
        backordersAllowed: backordersAllowed,
        backordered: backordered,
        soldIndividually: soldIndividually,
        weight: weight,
        dimensions: dimensions,
        shippingRequired: shippingRequired,
        shippingTaxable: shippingTaxable,
        shippingClass: shippingClass,
        shippingClassID: shippingClassID,
        productShippingClass: productShippingClass,
        reviewsAllowed: reviewsAllowed,
        averageRating: averageRating,
        ratingCount: ratingCount,
        relatedIDs: relatedIDs,
        upsellIDs: upsellIDs,
        crossSellIDs: crossSellIDs,
        parentID: parentID,
        purchaseNote: purchaseNote,
        categories: categories,
        tags: tags,
        images: images,
        attributes: attributes,
        defaultAttributes: defaultAttributes,
        variations: variations,
        groupedProducts: groupedProducts,
        menuOrder: menuOrder)
    }

    public func inventorySettingsUpdated(sku: String?,
                                         manageStock: Bool,
                                         soldIndividually: Bool,
                                         stockQuantity: Int?,
                                         backordersSetting: ProductBackordersSetting?,
                                         stockStatus: ProductStockStatus?) -> Product {
        return Product(siteID: siteID,
                       productID: productID,
                       name: name,
                       slug: slug,
                       permalink: permalink,
                       dateCreated: dateCreated,
                       dateModified: dateModified,
                       dateOnSaleStart: dateOnSaleStart,
                       dateOnSaleEnd: dateOnSaleEnd,
                       productTypeKey: productTypeKey,
                       statusKey: statusKey,
                       featured: featured,
                       catalogVisibilityKey: catalogVisibilityKey,
                       fullDescription: fullDescription,
                       briefDescription: briefDescription,
                       sku: sku,
                       price: price,
                       regularPrice: regularPrice,
                       salePrice: salePrice,
                       onSale: onSale,
                       purchasable: purchasable,
                       totalSales: totalSales,
                       virtual: virtual,
                       downloadable: downloadable,
                       downloads: downloads,
                       downloadLimit: downloadLimit,
                       downloadExpiry: downloadExpiry,
                       externalURL: externalURL,
                       taxStatusKey: taxStatusKey,
                       taxClass: taxClass,
                       manageStock: manageStock,
                       stockQuantity: stockQuantity,
                       stockStatusKey: stockStatus?.rawValue ?? stockStatusKey,
                       backordersKey: backordersSetting?.rawValue ?? backordersKey,
                       backordersAllowed: backordersAllowed,
                       backordered: backordered,
                       soldIndividually: soldIndividually,
                       weight: weight,
                       dimensions: dimensions,
                       shippingRequired: shippingRequired,
                       shippingTaxable: shippingTaxable,
                       shippingClass: shippingClass,
                       shippingClassID: shippingClassID,
                       productShippingClass: productShippingClass,
                       reviewsAllowed: reviewsAllowed,
                       averageRating: averageRating,
                       ratingCount: ratingCount,
                       relatedIDs: relatedIDs,
                       upsellIDs: upsellIDs,
                       crossSellIDs: crossSellIDs,
                       parentID: parentID,
                       purchaseNote: purchaseNote,
                       categories: categories,
                       tags: tags,
                       images: images,
                       attributes: attributes,
                       defaultAttributes: defaultAttributes,
                       variations: variations,
                       groupedProducts: groupedProducts,
                       menuOrder: menuOrder)
    }

    public func imagesUpdated(images: [ProductImage]) -> Product {
        return Product(siteID: siteID,
                       productID: productID,
                       name: name,
                       slug: slug,
                       permalink: permalink,
                       dateCreated: dateCreated,
                       dateModified: dateModified,
                       dateOnSaleStart: dateOnSaleStart,
                       dateOnSaleEnd: dateOnSaleEnd,
                       productTypeKey: productTypeKey,
                       statusKey: statusKey,
                       featured: featured,
                       catalogVisibilityKey: catalogVisibilityKey,
                       fullDescription: fullDescription,
                       briefDescription: briefDescription,
                       sku: sku,
                       price: price,
                       regularPrice: regularPrice,
                       salePrice: salePrice,
                       onSale: onSale,
                       purchasable: purchasable,
                       totalSales: totalSales,
                       virtual: virtual,
                       downloadable: downloadable,
                       downloads: downloads,
                       downloadLimit: downloadLimit,
                       downloadExpiry: downloadExpiry,
                       externalURL: externalURL,
                       taxStatusKey: taxStatusKey,
                       taxClass: taxClass,
                       manageStock: manageStock,
                       stockQuantity: stockQuantity,
                       stockStatusKey: stockStatusKey,
                       backordersKey: backordersKey,
                       backordersAllowed: backordersAllowed,
                       backordered: backordered,
                       soldIndividually: soldIndividually,
                       weight: weight,
                       dimensions: dimensions,
                       shippingRequired: shippingRequired,
                       shippingTaxable: shippingTaxable,
                       shippingClass: shippingClass,
                       shippingClassID: shippingClassID,
                       productShippingClass: productShippingClass,
                       reviewsAllowed: reviewsAllowed,
                       averageRating: averageRating,
                       ratingCount: ratingCount,
                       relatedIDs: relatedIDs,
                       upsellIDs: upsellIDs,
                       crossSellIDs: crossSellIDs,
                       parentID: parentID,
                       purchaseNote: purchaseNote,
                       categories: categories,
                       tags: tags,
                       images: images,
                       attributes: attributes,
                       defaultAttributes: defaultAttributes,
                       variations: variations,
                       groupedProducts: groupedProducts,
                       menuOrder: menuOrder)
    }
}
