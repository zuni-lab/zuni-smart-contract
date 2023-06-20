import "VerifiableDataRegistry"

pub fun main(subjectAddress: Address, did: String): &VerifiableDataRegistry.DIDDocument? {
    let subjectAccount = getAccount(subjectAddress)
    let didVaultCapability = subjectAccount.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
    let didVaultRef = didVaultCapability.borrow()

    if didVaultRef == nil {
        return nil
    }

    let didDocument = didVaultRef!.resolveDIDDocument(did: did)
    // log(dids)
    return didDocument
}
