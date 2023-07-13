import "VerifiableDataView"
import "VerifiableDataRegistry"

// pub fun main(issuerDID: String): [VerifiableDataView.RevocableVCView] {
//     let didPrefixLength = VerifiableDataView.DIDPrefix.length
//     let removedPrefixDID = issuerDID.slice(from: didPrefixLength, upTo: issuerDID.length)
//     let address = VerifiableDataRegistry.mapDIDToWallet[removedPrefixDID]
//     if(address == nil) {
//         return []
//     }
//     let revocableVCList = VerifiableDataView.getRevocableVCList(address: address!, did: issuerDID)
//     return revocableVCList
// }

pub fun main(issuerDID: String): Int {
    let didPrefixLength = VerifiableDataView.DIDPrefix.length
    let removedPrefixDID = issuerDID.slice(from: didPrefixLength, upTo: issuerDID.length)
    let address = VerifiableDataRegistry.mapDIDToWallet[removedPrefixDID]
    let account = getAccount(address!)
    let revocableVCVaultCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultRepresentation}>(VerifiableDataRegistry.RevocableVCVaultPublicPath)
    let revocableVCVaultRef = revocableVCVaultCap.borrow()

    if revocableVCVaultRef == nil {
        return 0
    }
    let revocableVCList: [VerifiableDataRegistry.RevocableVC] = revocableVCVaultRef!.getRevocableVCList(issuerDID: removedPrefixDID)

    return revocableVCList.length
}