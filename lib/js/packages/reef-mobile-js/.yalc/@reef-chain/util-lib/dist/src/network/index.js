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
  AVAILABLE_NETWORKS: () => import_network.AVAILABLE_NETWORKS,
  SS58_REEF: () => import_network.SS58_REEF,
  bonds: () => import_bonds.bonds,
  connectProvider: () => import_providerUtil.connectProvider,
  disconnectProvider: () => import_providerUtil.disconnectProvider,
  getLatestBlockAccountUpdates$: () => import_latestBlock.getLatestBlockAccountUpdates$,
  getLatestBlockContractEvents$: () => import_latestBlock.getLatestBlockContractEvents$,
  getLatestBlockUpdates$: () => import_latestBlock.getLatestBlockUpdates$,
  getReefswapNetworkConfig: () => import_dex.getReefswapNetworkConfig,
  initProvider: () => import_providerUtil.initProvider,
  reconnectProvider: () => import_providerUtil.reconnectProvider
});
module.exports = __toCommonJS(network_exports);
var import_network = require("./network");
var import_providerUtil = require("./providerUtil");
var import_dex = require("./dex");
var import_latestBlock = require("../reefState/latestBlock");
var import_bonds = require("./bonds");
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  AVAILABLE_NETWORKS,
  SS58_REEF,
  bonds,
  connectProvider,
  disconnectProvider,
  getLatestBlockAccountUpdates$,
  getLatestBlockContractEvents$,
  getLatestBlockUpdates$,
  getReefswapNetworkConfig,
  initProvider,
  reconnectProvider
});
