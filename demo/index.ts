import * as fcl from "@onflow/fcl";
import flowJSON from "../flow.json";
import { getDIDs, resolveDIDDocument } from "./scripts/verifiableDataRegistry";

async function main() {
  fcl
    .config({
      "flow.network": "local",
      "accessNode.api": "http://localhost:8888",
    })
    .load({ flowJSON });

  const address = "0xf8d6e0586b0a20c7";

  const dids = await getDIDs(address);
  console.log(dids);

  fcl
    .config({
      "flow.network": "local",
      "accessNode.api": "http://localhost:8888",
    })
    .load({ flowJSON });
  const didDocument = await resolveDIDDocument(address, dids[0]);
  console.log(didDocument);
}

main().catch((error) => console.error(error.message));
