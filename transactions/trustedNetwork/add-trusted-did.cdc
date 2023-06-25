import "TrustedNetwork"

transaction(did: String, trustedDID: String) {
    let trustedNetworkCap: Capability<&{TrustedNetwork.Owner}>
    
    prepare(acct: AuthAccount) {
        self.trustedNetworkCap = 
            acct.getCapability<&{TrustedNetwork.Owner}>(TrustedNetwork.TrustedNetworkManagementPrivatePath)    
    }

    pre {
        self.trustedNetworkCap.check() == true: "Trusted DID Network Capability doesn't exist"
    }

    execute {
        let trustedDIDOwnerRef = self.trustedNetworkCap.borrow()!
        trustedDIDOwnerRef.addTrustedDIDOf(did: did, newTrustedDID: trustedDID)

        log("Added new trusted DID ".concat(trustedDID))
    }
}