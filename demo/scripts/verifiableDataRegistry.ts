import * as fcl from "@onflow/fcl";
import * as fs from "fs";

export const getDIDs = async (address: String): Promise<String[]> => {
  const code = fs
    .readFileSync("../scripts/verifiableDataRegistry/get_dids.cdc")
    .toString();

  const dids = await fcl.query({
    cadence: code,
    args: (arg, t) => [arg(address, t.Address)],
  });

  return dids;
};

export const resolveDIDDocument = async (address: String, did: String) => {
  const code = fs
    .readFileSync("../scripts/verifiableDataRegistry/resolve_did_document.cdc")
    .toString();

  const didDocument = await fcl.query({
    cadence: code,
    args: (arg, t) => [arg(address, t.Address), arg(did, t.String)],
  });

  return didDocument;
};
