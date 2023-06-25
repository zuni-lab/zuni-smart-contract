import "VerifiableDataRegistry"

pub contract TrustedNetwork {
    pub let TrustedNetworkManagementStoragePath: StoragePath
    pub let TrustedNetworkManagementPrivatePath: PrivatePath
    pub let TrustedNetworkManagementPublicPath: PublicPath

    pub resource interface Viewer {
        pub fun getAllTrustedDIDsOf(did: String): [String]?
    }

    pub resource interface Owner {
        pub fun addTrustedDIDOf(did: String, newTrustedDID: String)
        pub fun removeExistedTrustedDIDOf(did: String, existedTrustedDID: String)
    }

    pub resource TrustedNetworkManagement: Viewer, Owner {
        pub let trustedNetworkOfDID: {String: [String]}

        init() {
            self.trustedNetworkOfDID = {}
        }

        pub fun getAllTrustedDIDsOf(did: String): [String]? {
            return self.trustedNetworkOfDID[did] 
        }

        pub fun addTrustedDIDOf(did: String, newTrustedDID: String) {
            let trustedDIDs = self.trustedNetworkOfDID[did]
            if trustedDIDs == nil {
                self.trustedNetworkOfDID[did] = [newTrustedDID]
            } else {
                self.trustedNetworkOfDID[did]!.append(newTrustedDID)
            }
        }

        pub fun removeExistedTrustedDIDOf(did: String, existedTrustedDID: String) {
            let trustedDIDs = self.trustedNetworkOfDID[did]
            if trustedDIDs == nil {
                panic("DID does not exist")
            } else {
                let indexOfExistedTrustedDID = self.trustedNetworkOfDID[did]!.firstIndex(of: existedTrustedDID)
                    ?? panic("Trusted DID does not exist")
                self.trustedNetworkOfDID[did]!.remove(at: indexOfExistedTrustedDID)
            }
        }
    }

    pub fun createTrustedNetworkManagement(): @TrustedNetworkManagement {
        return <-create TrustedNetworkManagement()        
    }

    init() {
        let trustedNetworkManagementIdentifier = "trustedNetworkManagement"
        self.TrustedNetworkManagementStoragePath = StoragePath(identifier: trustedNetworkManagementIdentifier)!
        self.TrustedNetworkManagementPrivatePath = PrivatePath(identifier: trustedNetworkManagementIdentifier)!
        self.TrustedNetworkManagementPublicPath = PublicPath(identifier: trustedNetworkManagementIdentifier)!
    }
}