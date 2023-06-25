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
        
        didVaultAuthRef.removeVerificationMethodForDID(did: did, verificationMethodId: verificationMethodId)

        log("Removed verification method from DID: ".concat(did))
    }
}