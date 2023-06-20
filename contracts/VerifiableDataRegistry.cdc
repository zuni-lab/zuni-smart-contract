pub contract VerifiableDataRegistry {
    pub let DIDPrefix: String
    pub let DIDVaultStoragePath: StoragePath
    pub let DIDVaultPrivatePath: PrivatePath
    pub let DIDVaultPublicPath: PublicPath

    pub let CountDIDsOnAddress: {Address: Int32}

    pub enum VerificationMethodType: UInt8 {
        pub case ECDSA_P256
        pub case ECDSA_secp256k1
        pub case BLS_BLS12_381
    }
    
    pub struct VerificationMethod {
        pub let id: String
        pub let type: VerificationMethodType
        pub let controller: String
        pub let publicKey: [UInt8]


        init(id: String, controller: String, type: VerificationMethodType, publicKey: [UInt8]) {
            self.id = id
            self.controller = controller
            self.type = type
            self.publicKey = publicKey            
        }
    }

    pub resource DIDDocument {
        pub let id: String
        pub let controller: String
        pub let alsoKnownAs: [String]
        pub let verificationMethod: {String: VerificationMethod}
        pub let authentication: [String]
        pub let assertionMethod: [String]
        pub let keyAgreement: [String]

        init(
            id: String, 
            controller: String, 
            alsoKnownAs: [String], 
            verificationMethod: VerificationMethod
        ) {
            let verificationKeyId = verificationMethod.id;

            self.id = id
            self.controller = controller
            self.alsoKnownAs = alsoKnownAs
            self.verificationMethod = {verificationKeyId: verificationMethod}
            self.authentication = [verificationKeyId]
            self.assertionMethod = [verificationKeyId]
            self.keyAgreement = [verificationKeyId]
        }

        pub fun addVerificationMethod(verificationMethod: VerificationMethod) {
            self.verificationMethod.insert(key: verificationMethod.id, verificationMethod)
        }

        pub fun removeVerificationMethod(verificationMethodId: String) {
            self.verificationMethod.remove(key: verificationMethodId)
        }
    }

    pub resource interface DIDRepresentation {
        pub fun getDIDs(): [String]

        pub fun resolveDIDDocument(did: String): &DIDDocument?
    }

    pub resource interface DIDAuthentication  {
        pub fun addDID(didDocument: @DIDDocument)

        pub fun removeDID(did: String): @DIDDocument
    }

    pub resource DIDVault: DIDAuthentication, DIDRepresentation {
        pub let didDocuments: @{String: DIDDocument}

        init() {
            self.didDocuments <- {}
        }

        pub fun addDID(didDocument: @DIDDocument) {
            let id = didDocument.id
            if self.didDocuments[id] != nil {
                panic("DID already exists")
            }
            self.didDocuments[id] <-! didDocument
        }

        pub fun removeDID(
            did: String
        ): @DIDDocument {
            let didDocument <- self.didDocuments.remove(key: did) ?? panic("DID not found")
            return <-didDocument
        }

        pub fun resolve(did: String): [String] {
            let DIDs = self.didDocuments.keys
            return DIDs
        }

        pub fun getDIDs(): [String] {
            let DIDs = self.didDocuments.keys
            return DIDs
        }

        pub fun resolveDIDDocument(did: String): &DIDDocument? {
            return &self.didDocuments[did] as &DIDDocument?
        }

        destroy() {
            destroy self.didDocuments
        }
    }

    pub fun createEmptyDIDVault(): @DIDVault {
        return <-create DIDVault()
    }

    pub fun registerDID(subjectAddress: Address, verificationPublicKey: [UInt8], verificationMethodType: UInt8): @DIDDocument {
        let nonce = self.CountDIDsOnAddress[subjectAddress] ?? 0
        let digest = HashAlgorithm.SHA2_256.hashWithTag(nonce.toBigEndianBytes(), tag: subjectAddress.toString())
        let identity = String.encodeHex(digest.slice(from: 0, upTo: 14))
        let did = self.DIDPrefix.concat(identity)

        self.CountDIDsOnAddress[subjectAddress] = nonce + 1

        let verificationMethod = VerificationMethod(
            id: did.concat("#keys-1"),
            controller: did,
            type: VerificationMethodType(rawValue: verificationMethodType)!,
            publicKey: verificationPublicKey
        )
        
        let didDocument <- create DIDDocument(
            id: did,
            controller: did,
            alsoKnownAs: [],
            verificationMethod: verificationMethod
        )
        return <-didDocument
    }

    init() {
        self.DIDPrefix = "did:flow:"

        let didVaultIdentifier = "didVault"
        self.DIDVaultStoragePath = StoragePath(identifier: didVaultIdentifier)!
        self.DIDVaultPrivatePath = PrivatePath(identifier: didVaultIdentifier)!
        self.DIDVaultPublicPath = PublicPath(identifier: didVaultIdentifier)!
        
        self.CountDIDsOnAddress = {}
    }
}