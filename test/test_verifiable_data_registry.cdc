import Test

import "VerifiableDataRegistry"

pub let blockchain = Test.newEmulatorBlockchain()
pub let subject = blockchain.createAccount()

pub let transactionsPath = "../transactions/verifiableDataRegistry/"
pub let scriptsPath = "../scripts/verifiableDataRegistry/"

pub fun setup() {
    let mockContractAccount = blockchain.createAccount()

    blockchain.useConfiguration(Test.Configuration({
        "VerifiableDataRegistry": mockContractAccount.address
    }))

    let code = Test.readFile("../contracts/VerifiableDataRegistry.cdc")
    let err = blockchain.deployContract(
        name: "VerifiableDataRegistry",
        code: code,
        account: mockContractAccount,
        arguments: []
    )

    Test.assert(err == nil)
}

pub fun testCreateEmptyDIDVault() {
    let code = Test.readFile(transactionsPath.concat("create_empty_did_vault.cdc"))
    let tx = Test.Transaction(
        code: code,
        authorizers: [subject.address],
        signers: [subject],
        arguments: []
    )

    let result = blockchain.executeTransaction(tx)
    
    Test.assert(result.status == Test.ResultStatus.succeeded)
}

pub fun testRegisterDID() {
    let code = Test.readFile(transactionsPath.concat("register_did.cdc"))
    let tx = Test.Transaction(
        code: code,
        authorizers: [subject.address],
        signers: [subject],
        arguments: []
    )
    let result = blockchain.executeTransaction(tx)
    Test.assert(result.status == Test.ResultStatus.succeeded)

    let getDIDsScript = Test.readFile(scriptsPath.concat("get_dids.cdc"))
    let didsResult = blockchain.executeScript(getDIDsScript, [subject.address])
    Test.assert(didsResult.status == Test.ResultStatus.succeeded)
    let dids = didsResult.returnValue! as! [String]
    Test.assert(dids.length == 1)

    let resolveDIDDocumentScript = Test.readFile(scriptsPath.concat("resolve_did_document.cdc"))
    let didDocumentResult = blockchain.executeScript(resolveDIDDocumentScript, [subject.address, dids[0]])
    log("pass")
    // Test.assert(didsResult.status == Test.ResultStatus.succeeded)
    // let didDocument = didDocumentResult.returnValue as &VerifiableDataRegistry.DIDDocument
    // Test.assert(didDocument.id == dids[0])
}