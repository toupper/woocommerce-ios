import SwiftUI

struct InPersonPaymentsStripeAccountPending: View {
    let deadline: Date?

    var body: some View {
          VStack {
              Spacer()

              VStack(alignment: .center, spacing: 42) {
                  Text(Localization.title)
                      .font(.headline)
                  Image(uiImage: .paymentErrorImage)
                      .resizable()
                      .scaledToFit()
                      .frame(height: 180.0)
                  Text(message)
                      .font(.callout)
                  InPersonPaymentsSupportLink()
              }
              .multilineTextAlignment(.center)

              Spacer()

              InPersonPaymentsLearnMore()
          }
          .padding(24.0)
      }

    private var message: String {
        guard let deadline = deadline else {
            DDLogError("In-Person Payments not avilable. Stripe has pending requirements without known deadline")
            return Localization.messageUnknownDeadline
        }
        return String(format: Localization.messageDeadline, deadline.toString(dateStyle: .medium, timeStyle: .none))
    }
}

private enum Localization {
    static let title = NSLocalizedString(
        "Your WooCommerce Payments account has pending requirements",
        comment: "Title for the error screen when the Stripe account is restricted because there are pending requirements"
    )

    static let messageDeadline = NSLocalizedString(
        "There are pending requirements in your account. Please complete those requirements by %1$@ to keep accepting in-Person Payments.",
        comment: "Error message when WooCommerce Payments is not supported because there are pending requirements in the Stripe account (with a known deadline)"
    )

    static let messageUnknownDeadline = NSLocalizedString(
        "There are pending requirements in your account. Please complete those requirements to keep accepting in-Person Payments.",
        comment: "Error message when WooCommerce Payments is not supported"
            +
            "There are pending requirements in the Stripe account (without a known deadline)"
    )

     static let message = NSLocalizedString(
         "There are pending requirements in your account. Please complete those requirements by",
         comment: "Error message when WooCommerce Payments is not supported because the Stripe account is under review"
     )
 }

struct InPersonPaymentsStripeAccountPending_Previews: PreviewProvider {
    static var previews: some View {
        InPersonPaymentsStripeAccountPending(deadline: Date())
    }
}
