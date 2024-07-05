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
var networkState_exports = {};
__export(networkState_exports, {
  ACTIVE_NETWORK_LS_KEY: () => ACTIVE_NETWORK_LS_KEY,
  rpcConfig: () => rpcConfig,
  selectedNetwork$: () => selectedNetwork$,
  setRpcConfig: () => setRpcConfig,
  setSelectedNetwork: () => setSelectedNetwork
});
module.exports = __toCommonJS(networkState_exports);
var import_rxjs = require("rxjs");
const selectedNetworkSubj = new import_rxjs.ReplaySubject(
  1
);
let rpcConfig = {};
const ACTIVE_NETWORK_LS_KEY = "reef-app-active-network";
const selectedNetwork$ = selectedNetworkSubj.asObservable();
const setSelectedNetwork = (network) => {
  if (network != null) {
    try {
      localStorage.setItem(ACTIVE_NETWORK_LS_KEY, JSON.stringify(network));
    } catch (e) {
    }
  }
  selectedNetworkSubj.next(network);
};
selectedNetwork$.subscribe(
  (network) => console.log("SELECTED NETWORK=", network.rpcUrl)
);
const setRpcConfig = (conf) => {
  rpcConfig = { ...rpcConfig, ...conf };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ACTIVE_NETWORK_LS_KEY,
  rpcConfig,
  selectedNetwork$,
  setRpcConfig,
  setSelectedNetwork
});
