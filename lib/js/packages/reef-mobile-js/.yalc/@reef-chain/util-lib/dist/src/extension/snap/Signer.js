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
let sendRequest;
class Signer {
  constructor(_sendRequest) {
    sendRequest = _sendRequest;
  }
  async signPayload(payload) {
    try {
      const result = await sendRequest("requestSignature", payload);
      if (!result)
        return Promise.reject(new Error("_canceled"));
      return { ...result };
    } catch (e) {
      return Promise.reject(new Error("_canceled"));
    }
  }
  async signRaw(payload) {
    try {
      const result = await sendRequest("requestSignature", payload);
      if (!result)
        return Promise.reject(new Error("_canceled"));
      return { ...result };
    } catch (e) {
      return Promise.reject(new Error("_canceled"));
    }
  }
}
