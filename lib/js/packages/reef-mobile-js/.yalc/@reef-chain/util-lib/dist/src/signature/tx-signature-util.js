var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var tx_signature_util_exports = {};
__export(tx_signature_util_exports, {
  decodePayloadMethod: () => decodePayloadMethod,
  getContractAbi: () => getContractAbi
});
module.exports = __toCommonJS(tx_signature_util_exports);
var import_types_known = require("@polkadot/types-known");
var import_types = require("@polkadot/types");
var import_util_crypto = require("@polkadot/util-crypto");
var import_ethers = require("ethers");
var import_token = require("../token");
var import_rxjs = require("rxjs");
var import_contractData = require("../graphql/contractData.gql");
var import_ERC20 = require("../token/abi/ERC20");
var import_httpClient = require("../graphql/httpClient");
var import_gqlUtil = require("../graphql/gqlUtil");
async function getContractAbi(contractAddress) {
  if (contractAddress === import_token.REEF_ADDRESS) {
    return Promise.resolve(import_ERC20.ERC20);
  }
  return (0, import_rxjs.firstValueFrom)(
    import_httpClient.httpClientInstance$.pipe(
      (0, import_rxjs.mergeMap)((httpClient) => fetchContractAbi$(httpClient, contractAddress)),
      (0, import_rxjs.map)((res) => {
        if (res[0] && res[0]["REEFERC20"]) {
          res = res[0];
        }
        let abiArr = [];
        res.forEach((ercDefinitionsObj) => {
          Object.keys(ercDefinitionsObj).forEach((ercKey) => {
            const ercDefinitionsObjAbi = ercDefinitionsObj[ercKey];
            abiArr = abiArr.concat(ercDefinitionsObjAbi);
          });
        });
        return abiArr;
      }),
      (0, import_rxjs.take)(1)
    )
  );
}
function fetchContractAbi$(httpClient, contractAddress) {
  return (0, import_gqlUtil.queryGql$)(httpClient, (0, import_contractData.getContractAbiQuery)(contractAddress)).pipe(
    (0, import_rxjs.take)(1),
    (0, import_rxjs.map)(
      (verContracts) => verContracts.data.verifiedContracts.map(
        // eslint-disable-next-line camelcase
        (vContract) => vContract.compiledData
      )
    ),
    (0, import_rxjs.catchError)((err) => {
      console.log("getContractAbi ERROR=", err);
      return (0, import_rxjs.of)(null);
    })
  );
}
async function decodePayloadMethod(provider, methodDataEncoded, abi, types) {
  const api = provider.api;
  await api.isReady;
  if (!types) {
    types = (0, import_types_known.getSpecTypes)(
      // @ts-ignore
      api.registry,
      api.runtimeChain.toString(),
      api.runtimeVersion.specName.toString(),
      api.runtimeVersion.specVersion
    );
  }
  let args = null;
  let method = null;
  try {
    const registry = new import_types.TypeRegistry();
    registry.register(types);
    registry.setChainProperties(
      // @ts-ignore
      registry.createType("ChainProperties", {
        ss58Format: 42,
        tokenDecimals: 18,
        tokenSymbol: "REEF"
      })
    );
    const metaCalls = (0, import_util_crypto.base64Encode)(api.runtimeMetadata.asCallsOnly.toU8a());
    const metadata = new import_types.Metadata(registry, (0, import_util_crypto.base64Decode)(metaCalls || ""));
    registry.setMetadata(metadata, void 0, void 0);
    method = registry.createType("Call", methodDataEncoded);
    args = (method?.toHuman()).args;
  } catch (error) {
    console.log("decodeMethod: ERROR decoding method");
    return null;
  }
  const info = method?.meta ? method.meta.docs.map((d) => d.toString().trim()).join(" ") : "";
  const methodParams = method?.meta ? `(${method.meta.args.map(({ name }) => name).join(", ")})` : "";
  const methodName = method ? `${method.section}.${method.method}${methodParams}` : "";
  const decodedResponse = {
    methodName,
    args,
    info,
    vm: {}
  };
  const isEvm = methodName.startsWith("evm.call");
  if (isEvm) {
    const contractAddress = args.target;
    let decodedData;
    if (!abi || !abi.length) {
      abi = await getContractAbi(contractAddress);
    }
    if (abi && abi.length && !!args) {
      const methodArgs = args.input;
      try {
        console.log("ABI can have duplicate member warnings");
        const iface = new import_ethers.ethers.utils.Interface(abi);
        decodedData = iface.parseTransaction({
          data: methodArgs,
          value: args.value
        });
      } catch (e) {
        console.log("ERROR decoding contract call err=", e.message);
      }
    }
    decodedResponse.vm["evm"] = {
      contractAddress,
      decodedData
    };
  }
  return decodedResponse;
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  decodePayloadMethod,
  getContractAbi
});
