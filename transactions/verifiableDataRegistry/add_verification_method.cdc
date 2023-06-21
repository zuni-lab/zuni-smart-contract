import "VerifiableDataRegistry"

transaction(did: String, publicKey: String, signatureAlgorithm: UInt8) {
    let didVaultAuthCap: Capability<&{VerifiableDataRegistry.DIDAuthentication}>
    
    prepare(subject: AuthAccount) {
        self.didVaultAuthCap = subject.getCapability<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath)    
    }

    pre {
        signatureAlgorithm < 3: "Invalid signature algorithm"
        self.didVaultAuthCap.check() == true: "DID Vault doesn't exist"
    }

    execute {
        let didVaultAuthRef = self.didVaultAuthCap.borrow()!
        let verificationKey = publicKey.decodeHex()
        let verificationMethodType = signatureAlgorithm
        didVaultAuthRef.addVerificationMethodForDID(did: did, verificationPublicKey: verificationKey, verificationMethodType: verificationMethodType)

        log("Added new verification method to DID: ".concat(did))
    }
}