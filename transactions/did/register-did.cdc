import "VerifiableDataRegistry"

transaction(keyId: String, verificationPublicKey: String, verificationMethodType: UInt8) {
    let didVaultCapability: Capability<&{VerifiableDataRegistry.DIDAuthentication}>
    let subjectAddress: Address

    prepare(register: AuthAccount) {
        self.didVaultCapability = register.getCapability<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath)     
        self.subjectAddress = register.address
    }

    pre {
        self.didVaultCapability.check() == true: "DID Vault doesn't exist"
    }

    execute {
        let subjectAccount = getAccount(self.subjectAddress)
        let newDIDDocument <- VerifiableDataRegistry.registerDID(
            subjectAddress: self.subjectAddress, 
            keyId: keyId,
            verificationPublicKey: verificationPublicKey.decodeHex(), 
            verificationMethodType: verificationMethodType
        )
        let did = newDIDDocument.id

        let didVaultRef = self.didVaultCapability.borrow()!
        didVaultRef.addDID(didDocument: <-newDIDDocument)

        log("new DID registered: ".concat(did))
    }
}