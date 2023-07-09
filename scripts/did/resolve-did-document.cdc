import "VerifiableDataRegistry"
import "VerifiableDataView"

pub fun main(did: String): VerifiableDataView.DIDDocumentView? {
    let didPrefixLength = VerifiableDataView.DIDPredix.length
    let removedPrefixDID = did.slice(from: didPrefixLength, upTo: did.length)
    let address = VerifiableDataRegistry.mapDIDToWallet[removedPrefixDID]
    if address == nil {
        return nil
    }
    let didDocumentView = VerifiableDataView.resolveDIDDocument(address: address!, did: did)
    return didDocumentView
}
