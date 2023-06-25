import "VerifiableDataRegistry"
import "DIDViews"

pub fun main(subjectAddress: Address, did: String): DIDViews.DIDDocumentView? {
    let subjectAccount = getAccount(subjectAddress)
    let didVaultCapability = subjectAccount.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
    let didVaultRef = didVaultCapability.borrow()
    if didVaultRef == nil {
        return nil
    }

    let didDocument = didVaultRef!.resolveDIDDocument(did: did)
    if didDocument == nil {
        return nil
    }
    log(didDocument)
    
    let didDocumentView = DIDViews.DIDDocumentView(didDocument: didDocument!)
    return didDocumentView
}
