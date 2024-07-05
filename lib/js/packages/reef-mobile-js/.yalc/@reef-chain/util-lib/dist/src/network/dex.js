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
var dex_exports = {};
__export(dex_exports, {
  REEFSWAP_CONFIG: () => REEFSWAP_CONFIG,
  getReefswapNetworkConfig: () => getReefswapNetworkConfig
});
module.exports = __toCommonJS(dex_exports);
const REEFSWAP_CONFIG = {
  mainnet: {
    factoryAddress: "0x380a9033500154872813F6E1120a81ed6c0760a8",
    routerAddress: "0x641e34931C03751BFED14C4087bA395303bEd1A5",
    graphqlDexsUrl: "https://squid.subsquid.io/reef-swap/graphql"
  },
  testnet: {
    factoryAddress: "0x9b9a32c56c8F5C131000Acb420734882Cc601d39",
    routerAddress: "0x614b7B6382524C32dDF4ff1f4187Bc0BAAC1ed11",
    graphqlDexsUrl: "https://squid.subsquid.io/reef-swap-testnet/graphql"
  },
  localhost: {
    factoryAddress: "",
    routerAddress: "",
    graphqlDexsUrl: "http://localhost:4351/graphql"
  }
};
const getReefswapNetworkConfig = (network) => {
  return REEFSWAP_CONFIG[network.name];
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  REEFSWAP_CONFIG,
  getReefswapNetworkConfig
});
