import "TrustedNetwork"

transaction(ownerDID: String) {
    prepare(subject: AuthAccount) {
         // Create a new empty collection
        let trustedNetwork <- TrustedNetwork.createTrustedNetworkManagement()

        // // store the empty TrustedNetworkManagement in account storage
        subject.save<@TrustedNetwork.TrustedNetworkManagement>(<-trustedNetwork, to: TrustedNetwork.TrustedNetworkManagementStoragePath)

        log("Trusted Network created for address ".concat(subject.address.toString()))

        // create a private capability for the TrustedDIDsList
        subject.link<&{TrustedNetwork.Owner}>(
            TrustedNetwork.TrustedNetworkManagementPrivatePath, 
            target: TrustedNetwork.TrustedNetworkManagementStoragePath
        )

        // create a public capability for the TrustedDIDsList
        subject.link<&{TrustedNetwork.Viewer}>(
            TrustedNetwork.TrustedNetworkManagementPublicPath, 
            target: TrustedNetwork.TrustedNetworkManagementStoragePath
        )

        log("Capability created")
    }
}