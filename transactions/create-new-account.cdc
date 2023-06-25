import "VerifiableDataRegistry"
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction(publicKey: String, signatureAlgo: UInt8, hashAlgo: UInt8) {    
    let sentVault: @FungibleToken.Vault
    let newAddress: Address

    prepare(creator: AuthAccount) {
        let newAccount = AuthAccount(payer: creator)
        newAccount.keys.add(
            publicKey: PublicKey(
                publicKey: publicKey.decodeHex(),
                signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgo)!
            ),
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgo)!,
            weight: 1000.0
        )
        self.newAddress = newAccount.address
        log("New account created: ".concat(self.newAddress.toString()))

        let vault = creator.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the sender's stored vault
        self.sentVault <- vault.withdraw(amount: 1.0)
        
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(self.newAddress)

        // Get a reference to the recipient's FungibleToken.Receiver
        let receiver = recipient
            .getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiver.deposit(from: <-self.sentVault)
    }
}