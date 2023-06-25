import * as fcl from "@onflow/fcl";
import fs from "fs";
import { ec as EC } from "elliptic";
import { SHA3 } from "sha3";

import flowJSON from "../flow.json";

// const ADDRESS = process.env.ADDRESS;
// const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ADDRESS = "0x0f7025fa05b578e3";
const PRIVATE_KEY =
  "eb3c84bc8171ec7da07b0804d7240b83dd5a9c5e3e6ad555515d00b732c420e0";

const ec = new EC("secp256k1");

const signWithKey = (privateKey: string, msgHex: string) => {
  const key = ec.keyFromPrivate(Buffer.from(privateKey, "hex"));
  const sig = key.sign(hashMsgHex(msgHex));
  const n = 32; // half of signature length?
  const r = sig.r.toArrayLike(Buffer, "be", n);
  const s = sig.s.toArrayLike(Buffer, "be", n);
  return Buffer.concat([r, s]).toString("hex");
};

const hashMsgHex = (msgHex: String) => {
  const sha = new SHA3(256);
  sha.update(Buffer.from(msgHex, "hex"));
  return sha.digest();
};

// Will be handled by fcl.user(addr).info()
const getAccount = async (addr: string) => {
  const { account } = await fcl.send([fcl.getAccount(addr) as any]);
  return account;
};

const authorization = async (account: any = {}) => {
  const user = await getAccount(ADDRESS);
  const key = user.keys[0];

  let sequenceNum;
  if (account.role && account.role.proposer) sequenceNum = key.sequenceNumber;

  const signingFunction = async (data: any) => {
    return {
      addr: user.address,
      keyId: key.index,
      signature: signWithKey(PRIVATE_KEY, data.message),
    };
  };

  return {
    ...account,
    addr: user.address,
    keyId: key.index,
    sequenceNum,
    signature: account.signature || null,
    signingFunction,
    resolve: null,
    roles: account.roles,
  };
};

const executeScript = async (script: string, args: object[] = []) =>
  fcl
    .send([fcl.getBlock(true) as any])
    .then(fcl.decode)
    .then((block) =>
      fcl.send([
        fcl.transaction(script),
        fcl.args(args),
        fcl.authorizations([authorization]),
        fcl.proposer(authorization),
        fcl.payer(authorization),
        fcl.ref(block.id),
        fcl.limit(100),
      ])
    )
    .then(({ transactionId }) => fcl.tx(transactionId).onceSealed())
    .catch((e) => {
      console.error(e);
    });

const main = async () => {
  fcl
    .config({
      "flow.network": "local",
      "accessNode.api": "http://localhost:8888",
    })
    .load({ flowJSON });

  const script = fs.readFileSync(
    "../transactions/verifiableDataRegistry/create_empty_did_vault.cdc",
    "utf8"
  );
  console.log(await getAccount(ADDRESS));
  // await executeScript(script);
  //   await executeScript(script, [fcl.arg(1, fcl.t.Int), fcl.arg(2, fcl.t.Int)]);
};

main();
