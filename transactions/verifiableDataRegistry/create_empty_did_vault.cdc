import "VerifiableDataRegistry"

transaction {
    prepare(register: AuthAccount) {
         // Create a new empty collection
        let vault <- VerifiableDataRegistry.createEmptyDIDVault()

        // // store the empty Vault in account storage
        register.save<@VerifiableDataRegistry.DIDVault>(<-vault, to: VerifiableDataRegistry.DIDVaultStoragePath)

        log("DID vault created for address ".concat(register.address.toString()))

        // create a public capability for the Vault
        register.link<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath, target: VerifiableDataRegistry.DIDVaultStoragePath)

        // create a public capability for the Vault
        register.link<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath, target: VerifiableDataRegistry.DIDVaultStoragePath)

        log("Capability created")
    }
}