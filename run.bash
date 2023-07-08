#!/bin/bash

ISSUER_ADDRESS="0xf8d6e0586b0a20c7"
ISSUER_DID="did:flow:9ef20515862a6a698d06a69cdf99d3f5"
VC_ID="12"
HOLDER_DID="did:flow:1234"

flow transactions send transactions/did/create-empty-did-vault.cdc
flow transactions send transactions/did/register-did.cdc 00cebc2791069a2ada8a5c105a7d12c065931abddd359db4c8582215282916153e14451da6a722b3fc204ad6d9fe3679043d8384028e7891962e9c167ee72cf6 2

flow scripts execute scripts/did/get-dids.cdc $ISSUER_ADDRESS
flow scripts execute scripts/did/resolve-did-document.cdc $ISSUER_ADDRESS $ISSUER_DID

flow transactions send transactions/vc/create-empty-vc-vault.cdc
flow transactions send transactions/vc/issue-vc.cdc $ISSUER_DID $VC_ID $HOLDER_DID

flow scripts execute scripts/vc/get-vc-list-by-did.cdc $ISSUER_ADDRESS $ISSUER_DID
flow scripts execute scripts/vc/get-vc.cdc $ISSUER_ADDRESS $ISSUER_DID $VC_ID