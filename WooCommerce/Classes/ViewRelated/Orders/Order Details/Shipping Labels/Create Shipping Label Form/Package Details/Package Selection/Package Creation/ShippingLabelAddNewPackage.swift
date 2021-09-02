import SwiftUI
import Yosemite

struct ShippingLabelAddNewPackage: View {
    @StateObject private var viewModel = ShippingLabelAddNewPackageViewModel()
    @StateObject private var customPackageVM = ShippingLabelCustomPackageFormViewModel()
    @StateObject private var servicePackageVM: ShippingLabelServicePackageListViewModel

    init(packagesResponse: ShippingLabelPackagesResponse?) {
        _servicePackageVM = StateObject(wrappedValue: ShippingLabelServicePackageListViewModel(packagesResponse: packagesResponse))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    SegmentedView(selection: $viewModel.selectedIndex, views: [Text(Localization.customPackage), Text(Localization.servicePackage)])
                        .frame(height: 44)
                    Divider()
                }
                .padding(.horizontal, insets: geometry.safeAreaInsets)

                ScrollView {
                    switch viewModel.selectedView {
                    case .customPackage:
                        ShippingLabelCustomPackageForm(viewModel: customPackageVM, safeAreaInsets: geometry.safeAreaInsets)
                    case .servicePackage:
                        ShippingLabelServicePackageList(viewModel: servicePackageVM, geometry: geometry)
                    }
                }
                 .background(Color(.listBackground).ignoresSafeArea(.container, edges: .bottom))
            }
            .ignoresSafeArea(.container, edges: .horizontal)
            .navigationTitle(Localization.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension ShippingLabelAddNewPackage {
    enum Localization {
        static let title = NSLocalizedString("Add New Package", comment: "Add New Package screen title in Shipping Label flow")
        static let customPackage = NSLocalizedString("Custom Package", comment: "Custom Package menu in Shipping Label Add New Package flow")
        static let servicePackage = NSLocalizedString("Service Package", comment: "Service Package menu in Shipping Label Add New Package flow")
    }
}

struct ShippingLabelAddNewPackage_Previews: PreviewProvider {
    static var previews: some View {
        ShippingLabelAddNewPackage(packagesResponse: ShippingLabelPackageDetailsViewModel.samplePackageDetails())
    }
}
