import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

transaction(receiver: Address, amount: UFix64) {    
    let sentVault: @FungibleToken.Vault

    prepare(creator: AuthAccount) {
        let vault = creator.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the sender's stored vault
        self.sentVault <- vault.withdraw(amount: amount)
        
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(receiver)

        // Get a reference to the recipient's FungibleToken.Receiver
        let receiver = recipient
            .getCapability(/public/flowTokenReceiver)
            .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiver.deposit(from: <-self.sentVault)
    }
}