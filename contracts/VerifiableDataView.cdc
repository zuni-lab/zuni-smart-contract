import "VerifiableDataRegistry"

pub contract VerifiableDataView {
    pub let DIDPrefix: String;
    pub let ControllerPrefix: String;

    pub struct VerificationMethodView {
        pub let id: String
        pub let type: String
        pub let controller: String
        pub let publicKey: String


        init(verificationMethod: VerifiableDataRegistry.VerificationMethod) {
            self.id = VerifiableDataView.DIDPrefix.concat(verificationMethod.id)
            self.controller = VerifiableDataView.ControllerPrefix.concat(verificationMethod.controller)
            self.publicKey = String.encodeHex(verificationMethod.publicKey)   

            switch verificationMethod.type {
                case VerifiableDataRegistry.VerificationMethodType.ECDSA_P256:
                    self.type = "ECDSA_P256"
                case VerifiableDataRegistry.VerificationMethodType.ECDSA_secp256k1:
                    self.type = "ECDSA_secp256k1"
                case VerifiableDataRegistry.VerificationMethodType.BLS_BLS12_381:
                    self.type = "BLS_BLS12_381"
                case VerifiableDataRegistry.VerificationMethodType.Unknown:
                    self.type = "Unknown"
                default:
                    self.type = "Unknown"
            }
        }
    }

    pub struct DIDDocumentView {
        pub let id: String
        pub let controller: String
        pub let alsoKnownAs: [String]
        pub let verificationMethod: [VerificationMethodView]
        pub let authentication: [String]
        pub let assertionMethod: [String]
        pub let keyAgreement: [String]

        init(didDocument: &VerifiableDataRegistry.DIDDocument) {
            let didPrefix = VerifiableDataView.DIDPrefix
            let controllerPrefix = VerifiableDataView.ControllerPrefix

            self.id = didPrefix.concat(didDocument.id)
            self.controller = controllerPrefix.concat(didDocument.controller)
            self.alsoKnownAs = didDocument.alsoKnownAs

            self.verificationMethod = []
            didDocument.verificationMethod.forEachKey(fun (key: String): Bool {
                let verificationMethodView = VerificationMethodView(
                    verificationMethod: didDocument.verificationMethod[key]!
                )
                let keyDID = didPrefix.concat(key)
                self.verificationMethod.append(verificationMethodView)

                return true
            })

            self.authentication = []
            for authentication in didDocument.authentication {
                self.authentication.append(didPrefix.concat(authentication))
            }

            self.assertionMethod = []
            for assertionMethod in didDocument.assertionMethod {
                self.assertionMethod.append(didPrefix.concat(assertionMethod))
            }

            self.keyAgreement = []
            for keyAgreement in didDocument.keyAgreement {
                self.keyAgreement.append(didPrefix.concat(keyAgreement))
            }
        }
    }

    pub struct RevocableVCView {
        pub let id: String
        pub let status: String

        init(revocableVC: VerifiableDataRegistry.RevocableVC) {
            self.id = revocableVC.id

            switch revocableVC.status {
                case VerifiableDataRegistry.VCStatus.Issued:
                    self.status = "Issued"
                case VerifiableDataRegistry.VCStatus.Revoked:
                    self.status = "Revoked"
                default:
                    self.status = "Unknown"
            }
        }
    }

    pub fun getDIDs(address: Address): [String] {
        let account = getAccount(address)
        let didVaultCapability = account.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
        let didVaultRef = didVaultCapability.borrow()

        if didVaultRef == nil {
            return []
        }

        let dids = didVaultRef!.getDIDs()
        let formattedDID: [String] = []
        for did in dids {
            formattedDID.append(self.DIDPrefix.concat(did))
        }
        return formattedDID
    }

    pub fun resolveDIDDocument(address: Address, did: String): DIDDocumentView? {
        let account = getAccount(address)
        let didVaultCapability = account.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
        let didVaultRef = didVaultCapability.borrow()
        if didVaultRef == nil {
            return nil
        }

        let didPrefixLength = self.DIDPrefix.length
        let removedPrefixDID = did.slice(from: didPrefixLength, upTo: did.length)
        let didDocument = didVaultRef!.resolveDIDDocument(did: removedPrefixDID)
        if didDocument == nil {
            return nil
        }
        
        let didDocumentView = VerifiableDataView.DIDDocumentView(didDocument: didDocument!)
        return didDocumentView
    }

    pub fun getRevocableVCList(address: Address, did: String): [RevocableVCView]  {
        let account = getAccount(address)
        let revocableVCVaultCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultRepresentation}>(VerifiableDataRegistry.RevocableVCVaultPublicPath)
        let revocableVCVaultRef = revocableVCVaultCap.borrow()

        if revocableVCVaultRef == nil {
            return []
        }

        let didPrefixLength = self.DIDPrefix.length
        let removedPrefixDID = did.slice(from: didPrefixLength, upTo: did.length)
        let revocableVCList = revocableVCVaultRef!.getRevocableVCList(issuerDID: removedPrefixDID)
        let formattedRevocableVCList: [VerifiableDataView.RevocableVCView] = []
        for revocableVC in revocableVCList {
            formattedRevocableVCList.append(VerifiableDataView.RevocableVCView(revocableVC: revocableVC))
        }   
        return formattedRevocableVCList
    }

    pub fun getRevocableVC(address: Address, did: String, id: String): RevocableVCView?  {
        let account = getAccount(address)
        let revocableVCVaultCap = account.getCapability<&{VerifiableDataRegistry.RevocableVCVaultRepresentation}>(VerifiableDataRegistry.RevocableVCVaultPublicPath)
        let revocableVCVaultRef = revocableVCVaultCap.borrow()

        if revocableVCVaultRef == nil {
            return nil
        }

        let didPrefixLength = self.DIDPrefix.length
        let removedPrefixDID = did.slice(from: didPrefixLength, upTo: did.length)
        let revocableVC = revocableVCVaultRef!.getRevocableVC(issuerDID: removedPrefixDID, id: id)
        
        if revocableVC == nil {
            return nil
        }
        
        let formattedRevocableVC = VerifiableDataView.RevocableVCView(revocableVC: revocableVC!)
        return formattedRevocableVC
    }

    init() {
        self.DIDPrefix = "did:flow:"
        self.ControllerPrefix = "did:flow:wallet:"
    }
}