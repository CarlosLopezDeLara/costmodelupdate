# Creating the Plutus V3 proposal 297 parameters

## Generate the cost model file that will be submitted in a proposal
### Produce a cost model file by flattening and merging builtinCostModelC.json and cekMachineCostsC.json

The first script downloads the builtins and CEK machine cost model JSON files from the Plutus repository and merges them into a single JSON file. The resulting file is [pv3-297-params-not-in-order.json](./outputs/pv3-297-params-not-in-order.json). It containins a map of the 297 parameters 
needed for the PlutusV3 cost model update. The parameters on this file are **NOT** in the correct order. However, one could use this file on 
a proposal, because it is a map. The node will sort it.  **But it would be very problematic to use it as source to convert it into a list.**


```shell
chmod +x ./scripts/*
```
```shell
./scripts/1-merge-builtins-cek.sh
```

To be extra cautions, we can run `scripts/2-createcostmodel.sh`. This script puts the cost model parameters in the order determined by [ParamName.hs](https://github.com/IntersectMBO/plutus/blob/1.36.0.0/plutus-ledger-api/src/PlutusLedgerApi/V3/ParamName.hs), the authoritative source for the order and names of the cost model parameters. This creates a cost model from scracth by processing `ParamName.hs`, it produces [pv3-297-params-ordered.json](./outputs/pv3-297-params-ordered.json)

```shell
./scripts/2-createcostmodel.sh
```

## Test results in local cluster

For this test I used preliminary verions of cardano-cli-10.0.0.0 and cardano-node-10.0.0 

```
❯ cardano-cli --version 
cardano-cli 9.4.1.0 - linux-x86_64 - ghc-8.10
git rev 6bc2b02cb5716418859654b7b25e61c4f474870a
```
```
❯ cardano-node --version 
cardano-node 9.2.0 - linux-x86_64 - ghc-8.10
git rev 9c7c941ee86af31313cb30924418817a8bac52dd
```
These versions are based on the current status of https://github.com/IntersectMBO/cardano-node/tree/mwojtowicz/release/node-9.3
at commit https://github.com/IntersectMBO/cardano-node/commit/9c7c941ee86af31313cb30924418817a8bac52dd

```
# Query the protocol parameters after enacting the proposal and count the parameters: |

TEST PASS: Cost model was successfully proposed and enacted, the parameter count is 297

# Compare the Enacted-cost-model vs proposed-cost-model vs reference-cost-model created by Thomas Velekoop, the order is identical on the 3 lists. 

TEST PASS: The order of the lists is identical in all files
```
The full log of the test is [here](outputs/costmodelupdate.txt)




