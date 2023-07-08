import "VerifiableDataView"

pub fun main(address: Address, did: String): [VerifiableDataView.RevocableVCView] {
    let revocableVCList = VerifiableDataView.getRevocableVCList(address: address, did: did)
    return revocableVCList
}
