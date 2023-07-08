import "VerifiableDataRegistry"

pub fun main(address: Address): Bool {
    let account = getAccount(address)
    let revocableVCVaultCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultRepresentation}>(VerifiableDataRegistry.RevocableVCVaultPublicPath)
    return revocableVCVaultCap.check()
}
