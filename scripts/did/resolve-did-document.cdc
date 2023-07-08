import "VerifiableDataRegistry"
import "VerifiableDataView"

pub fun main(address: Address, did: String): VerifiableDataView.DIDDocumentView? {
    let didDocumentView = VerifiableDataView.resolveDIDDocument(address: address, did: did)
    return didDocumentView
}
