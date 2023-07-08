import "VerifiableDataRegistry"

transaction {
    prepare(register: AuthAccount) {
         // Create a new empty collection
        let vault <- VerifiableDataRegistry.createEmptyRevocationVault()

        // // store the empty Vault in account storage
        register.save<@VerifiableDataRegistry.RevocableVCVault>(<-vault, to: VerifiableDataRegistry.RevocableVCVaultStoragePath)

        log("Revocable VC vault created for address ".concat(register.address.toString()))

        // create a private capability for the Vault
        register.link<&{VerifiableDataRegistry.RevocableVCVaultOwner}>(VerifiableDataRegistry.RevocableVCVaultPrivatePath, target: VerifiableDataRegistry.RevocableVCVaultStoragePath)

        // create a public capability for the Vault
        register.link<&{VerifiableDataRegistry.RevocableVCVaultRepresentation}>(VerifiableDataRegistry.RevocableVCVaultPublicPath, target: VerifiableDataRegistry.RevocableVCVaultStoragePath)

        log("Capability created")
    }
}