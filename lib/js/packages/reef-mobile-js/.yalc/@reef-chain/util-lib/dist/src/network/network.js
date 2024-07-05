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
var network_exports = {};
__export(network_exports, {
  AVAILABLE_NETWORKS: () => AVAILABLE_NETWORKS,
  SS58_REEF: () => SS58_REEF
});
module.exports = __toCommonJS(network_exports);
const SS58_REEF = 42;
const AVAILABLE_NETWORKS = {
  testnet: {
    name: "testnet",
    rpcUrl: "wss://rpc-testnet.reefscan.com/ws",
    reefscanUrl: "https://testnet.reefscan.com",
    verificationApiUrl: "https://api-testnet.reefscan.com",
    graphqlExplorerUrl: "wss://squid.subsquid.io/reef-explorer-testnet/graphql",
    genesisHash: "0xb414a8602b2251fa538d38a9322391500bd0324bc7ac6048845d57c37dd83fe6"
  },
  mainnet: {
    name: "mainnet",
    rpcUrl: "wss://rpc.reefscan.com/ws",
    reefscanUrl: "https://reefscan.com",
    verificationApiUrl: "https://api.reefscan.com",
    graphqlExplorerUrl: "wss://squid.subsquid.io/reef-explorer/graphql",
    genesisHash: "0x7834781d38e4798d548e34ec947d19deea29df148a7bf32484b7b24dacf8d4b7"
  },
  localhost: {
    name: "localhost",
    rpcUrl: "ws://localhost:9944",
    reefscanUrl: "http://localhost:8000",
    verificationApiUrl: "http://localhost:8001",
    graphqlExplorerUrl: "ws://localhost:8080/v1/graphql",
    genesisHash: ""
  }
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  AVAILABLE_NETWORKS,
  SS58_REEF
});
