import "VerifiableDataRegistry"

pub contract DIDViews {
    pub struct VerificationMethodView {
        pub let id: String
        pub let type: String
        pub let controller: String
        pub let publicKey: String


        init(verificationMethod: VerifiableDataRegistry.VerificationMethod) {
            self.id = verificationMethod.id
            self.controller = verificationMethod.controller
            self.publicKey = String.encodeHex(verificationMethod.publicKey)   

            switch verificationMethod.type {
                case VerifiableDataRegistry.VerificationMethodType.ECDSA_P256:
                    self.type = "ECDSA_P256"
                case VerifiableDataRegistry.VerificationMethodType.ECDSA_secp256k1:
                    self.type = "ECDSA_secp256k1"
                case VerifiableDataRegistry.VerificationMethodType.BLS_BLS12_381:
                    self.type = "BLS_BLS12_381"
                default:
                    self.type = "Unknown"
            }
        }
    }

    pub struct DIDDocumentView {
        pub let id: String
        pub let controller: String
        pub let alsoKnownAs: [String]
        pub let verificationMethod: {String: VerificationMethodView}
        pub let authentication: [String]
        pub let assertionMethod: [String]
        pub let keyAgreement: [String]

        init(didDocument: &VerifiableDataRegistry.DIDDocument) {
            self.id = didDocument.id
            self.controller = didDocument.controller
            self.alsoKnownAs = didDocument.alsoKnownAs
            self.authentication = didDocument.authentication
            self.assertionMethod = didDocument.assertionMethod
            self.keyAgreement = didDocument.keyAgreement
            self.verificationMethod = {}

            didDocument.verificationMethod.forEachKey(fun (key: String): Bool {
                let verificationMethodView = VerificationMethodView(verificationMethod: didDocument.verificationMethod[key]!)
                self.verificationMethod.insert(key: key, verificationMethodView)

                return true
            })
        }
    }
}