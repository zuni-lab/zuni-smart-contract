import "VerifiableDataRegistry"

transaction(issuerDID: String, id: String) {
    let issuerAddress: Address
    let vcVaultOwnerCap: Capability<&{VerifiableDataRegistry.RevocableVCVaultOwner}>
    
    prepare(account: AuthAccount) {
        self.issuerAddress = account.address
        self.vcVaultOwnerCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultOwner}>(VerifiableDataRegistry.RevocableVCVaultPublicPath)    
    }

    pre {
        self.vcVaultOwnerCap.check() == true: "VC Vault doesn't exist"
    }

    execute {
        let vcVaultAuthRef = self.vcVaultOwnerCap.borrow()!
        vcVaultAuthRef.revokeRevocableVC(issuerAddress: self.issuerAddress, issuerDID: issuerDID, id: id)

        log("Issued VC: ".concat(id))
    }
}