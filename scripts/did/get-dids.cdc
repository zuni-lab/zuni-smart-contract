import "VerifiableDataView"

pub fun main(subjectAddress: Address): [String] {
    let dids = VerifiableDataView.getDIDs(address: subjectAddress)
    return dids
}
