import "VerifiableDataRegistry"
import "VerifiableDataView"

pub fun main(issuerDID: String, id: String): Bool {
    let didPrefixLength = VerifiableDataView.DIDPrefix.length
    let removedPrefixDID = issuerDID.slice(from: didPrefixLength, upTo: issuerDID.length)
    let address = VerifiableDataRegistry.mapDIDToWallet[removedPrefixDID]
    if(address == nil) {
        return false
    }

    let revocableVC = VerifiableDataView.getRevocableVC(address: address!, did: issuerDID, id: id)
    if revocableVC == nil {
        return false
    }
    if revocableVC!.status == "Revoked" {
        return false
    }
    if revocableVC!.status != "Issued" {
        return false
    }
        
    return true
}
