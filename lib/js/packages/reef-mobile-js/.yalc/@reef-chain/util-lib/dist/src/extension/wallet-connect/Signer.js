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
var Signer_exports = {};
__export(Signer_exports, {
  default: () => Signer
});
module.exports = __toCommonJS(Signer_exports);
var import_utils = require("./utils");
let client;
let session;
class Signer {
  constructor(_client, _session) {
    client = _client;
    session = _session;
  }
  async signPayload(payload) {
    try {
      const result = await client.request({
        chainId: (0, import_utils.genesisHashToWcChainId)(payload.genesisHash),
        topic: session.topic,
        request: {
          method: import_utils.WC_DEFAULT_METHODS.REEF_SIGN_TRANSACTION,
          params: {
            address: payload.address,
            transactionPayload: payload
          }
        }
      });
      if (!result)
        return Promise.reject(new Error("_canceled"));
      return {
        id: 0,
        signature: result.signature
      };
    } catch (e) {
      if (e.toString().includes("Missing or invalid. Record was recently deleted")) {
        return Promise.reject(new Error("_invalid"));
      }
      return Promise.reject(new Error("_canceled"));
    }
  }
  async signRaw(payload) {
    try {
      const result = await client.request({
        chainId: import_utils.WC_MAINNET_CHAIN_ID,
        topic: session.topic,
        request: {
          method: import_utils.WC_DEFAULT_METHODS.REEF_SIGN_MESSAGE,
          params: {
            address: payload.address,
            message: payload.data
          }
        }
      });
      if (!result)
        return Promise.reject(new Error("_canceled"));
      return {
        id: 0,
        signature: result.signature
      };
    } catch (e) {
      return Promise.reject(new Error("_canceled"));
    }
  }
}
