import "VerifiableDataRegistry"

transaction(issuerDID: String, id: String) {
    let issuerAddress: Address
    let vcVaultOwnerCap: Capability<&{VerifiableDataRegistry.RevocableVCVaultOwner}>
    
    prepare(account: AuthAccount) {
        self.issuerAddress = account.address
        self.vcVaultOwnerCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultOwner}>(VerifiableDataRegistry.RevocableVCVaultPrivatePath)    
    }

    pre {
        self.vcVaultOwnerCap.check() == true: "VC Vault doesn't exist"
    }

    execute {
        let vcVaultAuthRef = self.vcVaultOwnerCap.borrow()!
        let didPrefixLength = "did:flow:".length
        let removedPrefixDID = issuerDID.slice(from: didPrefixLength, upTo: issuerDID.length)
        vcVaultAuthRef.issueRevocableVC(issuerAddress: self.issuerAddress, issuerDID: removedPrefixDID, id: id)

        log("Issued VC: ".concat(id))
    }
}