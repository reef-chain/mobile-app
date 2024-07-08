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
var ReefProvider_exports = {};
__export(ReefProvider_exports, {
  default: () => ReefProvider
});
module.exports = __toCommonJS(ReefProvider_exports);
var import_api = require("@polkadot/api");
var import_evm_provider = require("@reef-chain/evm-provider");
var import_network = require("../../network/network");
var import_utils = require("./utils");
let session;
class ReefProvider {
  constructor(_session) {
    this.rpcUrl = null;
    this.provider = null;
    session = _session;
  }
  subscribeSelectedNetwork(cb) {
    cb(this.rpcUrl || "");
  }
  subscribeSelectedNetworkProvider(cb) {
    if (this.provider) {
      cb(this.provider);
    }
    return () => {
    };
  }
  async getNetworkProvider() {
    const account = session.namespaces.reef?.accounts?.length ? session.namespaces.reef.accounts[0] : void 0;
    if (!account)
      throw new Error("Provider URL not found");
    let rpcUrl = void 0;
    if (account.startsWith(import_utils.WC_MAINNET_CHAIN_ID)) {
      rpcUrl = import_network.AVAILABLE_NETWORKS.mainnet.rpcUrl;
    } else if (account.startsWith(import_utils.WC_TESTNET_CHAIN_ID)) {
      rpcUrl = import_network.AVAILABLE_NETWORKS.testnet.rpcUrl;
    } else {
      throw new Error("Provider URL not found");
    }
    if (rpcUrl !== this.rpcUrl || !this.provider) {
      this.provider = new import_evm_provider.Provider({
        provider: new import_api.WsProvider(rpcUrl)
      });
    }
    try {
      await this.provider.api.isReadyOrError;
    } catch (e) {
      console.log("Provider API not ready", e);
      throw e;
    }
    this.rpcUrl = rpcUrl;
    return this.provider;
  }
}
