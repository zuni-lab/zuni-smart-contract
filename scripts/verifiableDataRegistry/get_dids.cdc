import "VerifiableDataRegistry"

pub fun main(subjectAddress: Address): [String] {
    let subjectAccount = getAccount(subjectAddress)
    let didVaultCapability = subjectAccount.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
    let didVaultRef = didVaultCapability.borrow()

    if didVaultRef == nil {
        return []
    }

    let dids = didVaultRef!.getDIDs()
    log(dids)
    return dids
}
