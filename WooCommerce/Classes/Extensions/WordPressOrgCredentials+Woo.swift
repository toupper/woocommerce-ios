import WordPressAuthenticator

extension WordPressOrgCredentials {

    /// Extracts the email associated to Jetpack, if available
    var jetPackEmail: String? {
        print(options)
        guard let email = options["jetpack_user_email"] as? [AnyHashable: Any] else {
            return nil
        }

        return email["value"] as? String
    }
}
