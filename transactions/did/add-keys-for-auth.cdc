import "VerifiableDataRegistry"
import "VerifiableDataView"

transaction(did: String, keyId: String, publicKey: String, signatureAlgorithm: UInt8) {
    let didVaultAuthCap: Capability<&{VerifiableDataRegistry.DIDAuthentication}>
    
    prepare(subject: AuthAccount) {
        self.didVaultAuthCap = subject.getCapability<&{VerifiableDataRegistry.DIDAuthentication}>(VerifiableDataRegistry.DIDVaultPrivatePath)    
    }

    pre {
        signatureAlgorithm < 3: "Invalid signature algorithm"
        self.didVaultAuthCap.check() == true: "DID Vault doesn't exist"
    }

    execute {
        let didPrefixLength = VerifiableDataView.DIDPrefix.length
        let removedPrefixDID = did.slice(from: didPrefixLength, upTo: did.length)
        
        let didVaultAuthRef = self.didVaultAuthCap.borrow()!
        let verificationKey = publicKey.decodeHex()
        let verificationMethodType = signatureAlgorithm
        didVaultAuthRef.addVerificationMethodForDID(
            did: removedPrefixDID, 
            keyId: keyId, 
            verificationPublicKey: verificationKey, 
            verificationMethodType: verificationMethodType
        )
        log("Added new verification method to DID: ".concat(did))

        let methodId = removedPrefixDID.concat("#".concat(keyId))
        didVaultAuthRef.addVerificationRelationshipsForDID(
            did: removedPrefixDID, 
            authentication: nil, 
            assertionMethod: methodId, 
            keyAgreement: methodId
        )
        log("Added new verification relationships for auth: ".concat(did))
    }
}