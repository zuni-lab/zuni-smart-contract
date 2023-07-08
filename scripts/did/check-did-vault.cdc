import "VerifiableDataRegistry"

pub fun main(subjectAddress: Address): Bool {
    let subjectAccount = getAccount(subjectAddress)
    let didVaultCapability = subjectAccount.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
    return didVaultCapability.check()
}
