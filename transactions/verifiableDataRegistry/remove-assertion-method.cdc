import "VerifiableDataRegistry"

transaction(did: String, assertionId: String) {
    let didVaultAuthCap: Capability<&{VerifiableDataRegistry.DIDAuthentication}>
    
    prepare(subject: AuthAccount) {
        self.didVaultAuthCap = subject.getCapability<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath)    
    }

    pre {
        self.didVaultAuthCap.check() == true: "DID Vault doesn't exist"
    }

    execute {
        let didVaultAuthRef = self.didVaultAuthCap.borrow()!
        didVaultAuthRef.removeAssertionRelationship(did: did, assertionId: assertionId)

        log("Removed verification relationship in assertionMethod: ".concat(assertionId))
    }
}