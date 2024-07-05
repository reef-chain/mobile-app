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
var utils_exports = {};
__export(utils_exports, {
  WC_DEFAULT_METHODS: () => WC_DEFAULT_METHODS,
  WC_MAINNET_CHAIN_ID: () => WC_MAINNET_CHAIN_ID,
  WC_TESTNET_CHAIN_ID: () => WC_TESTNET_CHAIN_ID,
  genesisHashToWcChainId: () => genesisHashToWcChainId,
  getWcRequiredNamespaces: () => getWcRequiredNamespaces
});
module.exports = __toCommonJS(utils_exports);
var import_network = require("../../network");
var WC_DEFAULT_METHODS = /* @__PURE__ */ ((WC_DEFAULT_METHODS2) => {
  WC_DEFAULT_METHODS2["REEF_SIGN_TRANSACTION"] = "reef_signTransaction";
  WC_DEFAULT_METHODS2["REEF_SIGN_MESSAGE"] = "reef_signMessage";
  return WC_DEFAULT_METHODS2;
})(WC_DEFAULT_METHODS || {});
const genesisHashToWcChainId = (genesisHash) => {
  return `reef:${genesisHash.substring(2, 34)}`;
};
const WC_MAINNET_CHAIN_ID = genesisHashToWcChainId(
  import_network.AVAILABLE_NETWORKS.mainnet.genesisHash
);
const WC_TESTNET_CHAIN_ID = genesisHashToWcChainId(
  import_network.AVAILABLE_NETWORKS.testnet.genesisHash
);
const getWcRequiredNamespaces = () => {
  return {
    reef: {
      methods: Object.values(WC_DEFAULT_METHODS),
      chains: [
        genesisHashToWcChainId(import_network.AVAILABLE_NETWORKS["mainnet"].genesisHash),
        genesisHashToWcChainId(import_network.AVAILABLE_NETWORKS["testnet"].genesisHash)
      ],
      events: []
    }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  WC_DEFAULT_METHODS,
  WC_MAINNET_CHAIN_ID,
  WC_TESTNET_CHAIN_ID,
  genesisHashToWcChainId,
  getWcRequiredNamespaces
});
