import "VerifiableDataRegistry"

transaction {
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
        let subjectKey = subjectAccount.keys.get(keyIndex: 0)!
        let verificationPublicKey = subjectKey.publicKey.publicKey
        let verificationMethodType = subjectKey.publicKey.signatureAlgorithm.rawValue

        let newDIDDocument <- VerifiableDataRegistry.registerDID(subjectAddress: self.subjectAddress, verificationPublicKey: verificationPublicKey, verificationMethodType: verificationMethodType)
        let did = newDIDDocument.id

        let didVaultRef = self.didVaultCapability.borrow()!
        didVaultRef.addDID(didDocument: <-newDIDDocument)

        log("new DID registered: ".concat(did))
    }
}