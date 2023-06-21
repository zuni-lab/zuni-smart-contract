import "VerifiableDataRegistry"

transaction(did: String, verificationMethodId: String) {
    let didVaultAuthCap: Capability<&{VerifiableDataRegistry.DIDAuthentication}>
    
    prepare(subject: AuthAccount) {
        self.didVaultAuthCap = subject.getCapability<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath)    
    }

    pre {
        self.didVaultAuthCap.check() == true: "DID Vault doesn't exist"
    }

    execute {
        let didVaultAuthRef = self.didVaultAuthCap.borrow()!
        didVaultAuthRef.addVerificationRelationshipsForDID(did: did, authentication: [], assertionMethod: [verificationMethodId], keyAgreement: [])

        log("Added verification relationship in assertionMethod in DID: ".concat(did))
    }
}