import "TrustedNetwork"

pub fun main(subjectAddress: Address, did: String): [String] {
    let subjectAccount = getAccount(subjectAddress)
    let trustedNetworkCap = 
        subjectAccount.getCapability<&{TrustedNetwork.Viewer}>(TrustedNetwork.TrustedNetworkManagementPublicPath)
    let trustedNetworkRef = trustedNetworkCap.borrow()

    if trustedNetworkRef == nil {
        return []
    }

    let dids = trustedNetworkRef!.getAllTrustedDIDsOf(did: did)
    if dids == nil {
        return []
    }
    return dids!
}
