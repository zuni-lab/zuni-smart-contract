import * as fcl from "@onflow/fcl";
import * as fs from "fs";
import flowJSON from "../flow.json";

async function main() {
  fcl
    .config({
      "flow.network": "local",
      "accessNode.api": "http://localhost:8888",
    })
    .load({ flowJSON });

  const result = await fcl.query({
    cadence: `
        pub fun main(a: Int, b: Int, addr: Address): Int {
          log(addr)
          return a + b
        }
      `,
    args: (arg, t) => [
      arg("7", t.Int), // a: Int
      arg("6", t.Int), // b: Int
      arg("0xba1132bc08f82fe2", t.Address), // addr: Address
    ],
  });

  console.log(result); // [Point{x:1, y:1}, Point{x:2, y:2}]
}

main().catch((error) => console.error(error.message));
