import "VerifiableDataView"

pub fun main(address: Address, did: String, id: String): VerifiableDataView.RevocableVCView? {
    let revocableVC = VerifiableDataView.getRevocableVC(address: address, did: did, id: id)
    return revocableVC
}
