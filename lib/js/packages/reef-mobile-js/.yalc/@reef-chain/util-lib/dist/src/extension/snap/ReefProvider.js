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
class ReefProvider {
  constructor(_sendRequest) {
    this.rpcUrl = null;
    this.provider = null;
    this.sendRequest = _sendRequest;
    this.getNetworkProvider();
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
    const network = await this.sendRequest("getNetwork");
    if (!network?.rpcUrl)
      throw new Error("Provider URL not found");
    if (network.rpcUrl !== this.rpcUrl || !this.provider) {
      this.provider = new import_evm_provider.Provider({
        provider: new import_api.WsProvider(network.rpcUrl)
      });
    }
    try {
      await this.provider.api.isReadyOrError;
    } catch (e) {
      console.log("Provider API not ready", e);
      throw e;
    }
    this.rpcUrl = network.rpcUrl;
    return this.provider;
  }
}
