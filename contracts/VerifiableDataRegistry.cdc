pub contract VerifiableDataRegistry {
    pub let DIDVaultStoragePath: StoragePath
    pub let DIDVaultPrivatePath: PrivatePath
    pub let DIDVaultPublicPath: PublicPath
    pub let RevocableVCVaultStoragePath: StoragePath
    pub let RevocableVCVaultPrivatePath: PrivatePath
    pub let RevocableVCVaultPublicPath: PublicPath
    pub let CountDIDsOnAddress: {Address: Int32}
    pub let mapDIDToWallet: {String: Address}

    pub event DIDRegistered(did: String)
    pub event RevocableVCIssued(issuerDID: String, id: String)
    pub event RevocableVCRevoked(issuerDID: String, id: String)

    pub enum VerificationMethodType: UInt8 {
        pub case Unknown
        pub case ECDSA_P256
        pub case ECDSA_secp256k1
        pub case BLS_BLS12_381
    }
    pub enum VCStatus: UInt8 {
        pub case Issued
        pub case Revoked
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

    pub struct RevocableVC {
        pub let id: String
        pub let holderDID: String
        pub var status: VCStatus

        init(id: String, holderDID: String, status: VCStatus) {
            self.id = id
            self.holderDID = holderDID
            self.status = status
        }

        pub fun revoke() {
            if self.status == VCStatus.Issued {
                self.status = VCStatus.Revoked
            }
        }
    }

    pub struct RevocableVCList {
        pub let issuerDID: String
        pub let revocableVC: {String: RevocableVC}

        init(issuerDID: String) {
            self.issuerDID = issuerDID
            self.revocableVC = {}
        }

        pub fun issueRevocableVC(id: String, holderDID: String) {
            if self.revocableVC[id] != nil {
                panic("Revocable VC already exists")
            }
            let revocableVC = RevocableVC(
                id: id,
                holderDID: holderDID,
                status: VCStatus.Issued
            )
            self.revocableVC[id] = revocableVC
        }

        pub fun revokeRevocableVC(id: String) {
            if self.revocableVC[id] == nil {
                panic("Revocable VC not found")
            }
            self.revocableVC[id]?.revoke()
        }

        pub fun getRevocableVC(id: String): RevocableVC? {
            return self.revocableVC[id]
        }

        pub fun getRevocableVCList(): [RevocableVC] {
            return self.revocableVC.values
        }
    }

    pub resource interface DIDRepresentation {
        pub fun getDIDs(): [String]

        pub fun resolveDIDDocument(did: String): &DIDDocument?
    }

    pub resource interface DIDAuthentication  {
        pub fun addDID(didDocument: @DIDDocument)
        
        pub fun removeDID(did: String): @DIDDocument

        pub fun addVerificationMethodForDID(
            did: String, 
            keyId: String, 
            verificationPublicKey: [UInt8], 
            verificationMethodType: UInt8
        )

        pub fun removeVerificationMethodForDID(did: String, verificationMethodId: String)

        pub fun addVerificationRelationshipsForDID(
            did: String,
            authentication: String?, 
            assertionMethod: String?,
            keyAgreement: String?
        )

        pub fun removeAuthenticationRelationship(did: String, authenticationId: String)

        pub fun removeAssertionRelationship(did: String, assertionId: String)

        pub fun removeKeyAgreementRelationship(did: String, keyAgreementId: String)
    }

     pub resource interface RevocableVCVaultRepresentation {
        pub fun getRevocableVC(issuerDID: String, id: String): RevocableVC?

        pub fun getRevocableVCList(issuerDID: String): [RevocableVC]
    }

    pub resource interface RevocableVCVaultOwner  {
        pub fun issueRevocableVC(issuerAddress: Address, issuerDID: String, id: String, holderDID: String)
        
        pub fun revokeRevocableVC(issuerAddress: Address, issuerDID: String, id: String)
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

        pub fun addVerificationMethod(_ verificationMethod: VerificationMethod) {
            let key = verificationMethod.id
            if self.verificationMethod[key] != nil {
                panic("Verification method already exists")
            }

            self.verificationMethod.insert(key: verificationMethod.id, verificationMethod)
        }

        pub fun removeVerificationMethod(_ verificationMethodId: String) {
            if self.verificationMethod[verificationMethodId] == nil {
                panic("Verification method does not exist")
            }

            self.verificationMethod.remove(key: verificationMethodId)
        }

        pub fun addVerificationRelationships(
            authentication: String?, 
            assertionMethod: String?, 
            keyAgreement: String?
        ) {
            if authentication != nil {
                if self.authentication.contains(authentication!) {
                    panic("Authentication relationship already exists")
                }
                self.authentication.append(authentication!)
            }
            if assertionMethod != nil {
                if self.assertionMethod.contains(assertionMethod!) {
                    panic("assertionMethod relationship already exists")
                }
                self.assertionMethod.append(assertionMethod!)
            }
            if keyAgreement != nil {
                if self.keyAgreement.contains(keyAgreement!) {
                    panic("keyAgreement relationship already exists")
                }
                self.keyAgreement.append(keyAgreement!)
            }
        }

        pub fun removeAuthenticationRelationship(
            authenticationId: String,
        ) {
            for index, authen in self.authentication {
                if authen == authenticationId {
                    self.authentication.remove(at: index)
                    break
                }
            }
        }

        pub fun removeAssertionRelationship(
            assertionId: String,
        ) {
            for index, assertion in self.assertionMethod {
                if assertion == assertionId {
                    self.assertionMethod.remove(at: index)
                    break
                }
            }
        }

        pub fun removeKeyAgreementRelationship(
            keyAgreementId: String,
        ) {
            for index, keyAgreement in self.keyAgreement {
                if keyAgreement == keyAgreementId {
                    self.authentication.remove(at: index)
                    break
                }
            }
        }
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

        pub fun addVerificationMethodForDID(did: String, keyId: String, verificationPublicKey: [UInt8], verificationMethodType: UInt8) {
           pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found") 
            let methodId = did.concat("#").concat(keyId)
            let verificationMethod = VerificationMethod(
                id: methodId,
                controller: did,
                type: VerificationMethodType(rawValue: verificationMethodType)!,
                publicKey: verificationPublicKey
            )
            didDocument.addVerificationMethod(verificationMethod)
            self.didDocuments[did] <-! didDocument
        }

        pub fun removeVerificationMethodForDID(did: String, verificationMethodId: String) {
            pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found")
            didDocument.removeVerificationMethod(verificationMethodId)
            self.didDocuments[did] <-! didDocument
        }

        pub fun addVerificationRelationshipsForDID(
            did: String,
            authentication: String?, 
            assertionMethod: String?,
            keyAgreement: String?
        ) {
            pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found")
            didDocument.addVerificationRelationships(authentication: authentication, assertionMethod: assertionMethod, keyAgreement: keyAgreement)
            self.didDocuments[did] <-! didDocument
        }

        pub fun removeAuthenticationRelationship(
            did: String,
            authenticationId: String,
        ) {
            pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found")
            didDocument.removeAuthenticationRelationship(authenticationId: authenticationId)
            self.didDocuments[did] <-! didDocument
        }

        pub fun removeAssertionRelationship(
            did: String,
            assertionId: String,
        ) {
            pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found")
            didDocument.removeAssertionRelationship(assertionId: assertionId)
            self.didDocuments[did] <-! didDocument
        }

        pub fun removeKeyAgreementRelationship(
            did: String,
            keyAgreementId: String,
        ) {
            pre {
                self.didDocuments[did] != nil
            }

            let didDocument <-self.didDocuments.remove(key: did) ?? panic("DID not found")
            didDocument.removeKeyAgreementRelationship(keyAgreementId: keyAgreementId)
            self.didDocuments[did] <-! didDocument
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

    pub resource RevocableVCVault: RevocableVCVaultOwner, RevocableVCVaultRepresentation {
        pub let revocableVCListByDID: {String: RevocableVCList}

        init() {
            self.revocableVCListByDID = {}
        }

        pub fun issueRevocableVC(
            issuerAddress: Address,
            issuerDID: String,
            id: String,
            holderDID: String
        ) {
            let account = getAccount(issuerAddress)
            let didVaultCapability = account.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
            let didVaultRef = didVaultCapability.borrow()
            if didVaultRef == nil {
                panic("Not found DID Vault")
            }
            let dids = didVaultRef!.getDIDs()
            if !dids.contains(issuerDID) {
                panic("Not own this DID")
            }
            
            if self.revocableVCListByDID[issuerDID] == nil {
                let revocableVCs = RevocableVCList(
                    issuerDID: issuerDID
                )
                self.revocableVCListByDID[issuerDID] = revocableVCs
            }
            self.revocableVCListByDID[issuerDID]?.issueRevocableVC(
                id: id,
                holderDID: holderDID
            )
        }

        pub fun revokeRevocableVC(
            issuerAddress: Address,
            issuerDID: String,
            id: String
        ) {
            let account = getAccount(issuerAddress)
            let didVaultCapability = account.getCapability<&{VerifiableDataRegistry.DIDRepresentation}>(VerifiableDataRegistry.DIDVaultPublicPath)
            let didVaultRef = didVaultCapability.borrow()
            if didVaultRef == nil {
                panic("Not found DID Vault")
            }
            let dids = didVaultRef!.getDIDs()
            if !dids.contains(issuerDID) {
                panic("Not own this DID")
            }

            if self.revocableVCListByDID[issuerDID] == nil {
                panic("Not found Revocable VC List")
            }
            self.revocableVCListByDID[issuerDID]?.revokeRevocableVC(
                id: id,
            )
        }

        pub fun getRevocableVC(issuerDID: String, id: String): RevocableVC? {
            if self.revocableVCListByDID[issuerDID] == nil {
                return nil
            }
            return self.revocableVCListByDID[issuerDID]!.getRevocableVC(id: id)
        }

        pub fun getRevocableVCList(issuerDID: String): [RevocableVC] {
            if self.revocableVCListByDID[issuerDID] == nil {
                return []
            }
            return self.revocableVCListByDID[issuerDID]!.getRevocableVCList()
        }
    }

    pub fun createEmptyDIDVault(): @DIDVault {
        return <-create DIDVault()
    }

    pub fun createEmptyRevocationVault(): @RevocableVCVault {
        return <-create RevocableVCVault()
    }

    pub fun registerDID(subjectAddress: Address, keyId: String, verificationPublicKey: [UInt8], verificationMethodType: UInt8): @DIDDocument {
        let nonce = self.CountDIDsOnAddress[subjectAddress] ?? 0
        let digest = HashAlgorithm.SHA2_256.hashWithTag(nonce.toBigEndianBytes(), tag: subjectAddress.toString())
        let did = String.encodeHex(digest.slice(from: 0, upTo: 16))

        let controller = self.account.address.toString()
        let methodId = did.concat("#").concat(keyId)
        let verificationMethod = VerificationMethod(
            id: methodId,
            controller: controller,
            type: VerificationMethodType(rawValue: verificationMethodType)!,
            publicKey: verificationPublicKey
        )
        
        let didDocument <- create DIDDocument(
            id: did,
            controller: controller,
            alsoKnownAs: [],
            verificationMethod: verificationMethod
        )
        self.mapDIDToWallet[did] = subjectAddress
        self.CountDIDsOnAddress[subjectAddress] = nonce + 1

        emit DIDRegistered(did: did)

        return <-didDocument
    }

    init() {
        let didVaultIdentifier = "didVault"
        self.DIDVaultStoragePath = StoragePath(identifier: didVaultIdentifier)!
        self.DIDVaultPrivatePath = PrivatePath(identifier: didVaultIdentifier)!
        self.DIDVaultPublicPath = PublicPath(identifier: didVaultIdentifier)!

        let revocableVCVaultIdentifier = "revocableVCVault"
        self.RevocableVCVaultStoragePath = StoragePath(identifier: revocableVCVaultIdentifier)!
        self.RevocableVCVaultPrivatePath = PrivatePath(identifier: revocableVCVaultIdentifier)!
        self.RevocableVCVaultPublicPath = PublicPath(identifier: revocableVCVaultIdentifier)!
        
        self.CountDIDsOnAddress = {}
        self.mapDIDToWallet = {}
    }
}