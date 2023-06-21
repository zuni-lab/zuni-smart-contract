#!/bin/bash

# flow transactions send transactions/verifiableDataRegistry/create_empty_did_vault.cdc
# flow transactions send transactions/verifiableDataRegistry/register_did.cdc

DID="did:flow:30e9a7a97a01bd88f3523057e523"
PUBLIC_KEY="4c8fbd44abd7c60c705a38f47138ca23a4edf32ca7ba477e551b1e3577dfbd07e133706f3429ac3992d9aa1f86ffc2f5ed27891ad7070600649fd66964b24d12"
SIGNATURE_ALGORITHM="2"


flow transactions send transactions/verifiableDataRegistry/add_verification_method.cdc $DID $PUBLIC_KEY $SIGNATURE_ALGORITHM

# METHOD_ID="did:flow:30e9a7a97a01bd88f3523057e5234c8fbd44abd2160c705a38f47138ca23a4edf32ca7ba477e551b1e3577dfbd07"
# flow transactions send transactions/verifiableDataRegistry/remove_verification_method.cdc $DID $PUBLIC_KEY $METHOD_ID