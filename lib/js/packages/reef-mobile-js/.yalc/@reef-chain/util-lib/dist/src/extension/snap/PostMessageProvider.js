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
var PostMessageProvider_exports = {};
__export(PostMessageProvider_exports, {
  default: () => PostMessageProvider
});
module.exports = __toCommonJS(PostMessageProvider_exports);
let sendRequest;
class PostMessageProvider {
  constructor(_sendRequest) {
    this._isConnected = false;
    this._isClonable = false;
    sendRequest = _sendRequest;
  }
  get hasSubscriptions() {
    return false;
  }
  get isConnected() {
    return this._isConnected;
  }
  get isClonable() {
    return this._isClonable;
  }
  clone() {
    if (!this.isClonable) {
      throw new Error("Unclonable provider");
    }
    return new PostMessageProvider(sendRequest);
  }
  async connect() {
    console.error("PostMessageProvider.disconnect() is not implemented.");
  }
  async disconnect() {
    console.error("PostMessageProvider.disconnect() is not implemented.");
  }
  listProviders() {
    throw new Error("PostMessageProvider.listProviders() is not implemented.");
  }
  on(_type, _sub) {
    console.error("PostMessageProvider.on() is not implemented.");
    return () => {
    };
  }
  async send(_method, _params, _isCacheable) {
    console.error("PostMessageProvider.send() is not implemented.");
  }
  async startProvider(_key) {
    throw new Error("PostMessageProvider.startProvider() is not implemented.");
  }
  subscribe(_type, method, params, _callback) {
    return this.send(method, params);
  }
  async unsubscribe(_type, _method, _id) {
    console.error("PostMessageProvider.unsubscribe() is not implemented.");
    return false;
  }
}
