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
var providerState_exports = {};
__export(providerState_exports, {
  instantProvider$: () => instantProvider$,
  providerConnState$: () => providerConnState$,
  selectedNetworkProvider$: () => selectedNetworkProvider$,
  selectedProvider$: () => selectedProvider$
});
module.exports = __toCommonJS(providerState_exports);
var import_rxjs = require("rxjs");
var import_providerUtil = require("../network/providerUtil");
var import_operators = require("rxjs/operators");
var import_networkState = require("./networkState");
var import_ws_connection_state = require("./ws-connection-state");
var import_force_reload_tokens = require("./token/force-reload-tokens");
const providerConnStateSubj = new import_rxjs.Subject();
const providerConnState$ = (0, import_ws_connection_state.getCollectedWsStateValue$)(providerConnStateSubj);
async function connectProvider(currNet, rpcConfig2) {
  try {
    const iProvider = currNet.options?.initProvider || import_providerUtil.initProvider;
    const pr = await iProvider(
      currNet.rpcUrl,
      providerConnStateSubj,
      rpcConfig2
    );
    return { provider: pr, network: currNet };
  } catch (err) {
    console.log("ERR connectProvider=", err.message);
    return { provider: void 0, network: currNet };
  }
}
const selectedNetworkProvider$ = import_networkState.selectedNetwork$.pipe(
  (0, import_rxjs.combineLatestWith)(import_force_reload_tokens.forceReload$),
  (0, import_rxjs.mergeScan)(
    (pr_url, [currNet, _]) => {
      if (pr_url.network?.rpcUrl === currNet.rpcUrl && !!pr_url.provider && pr_url.provider.api.isConnected) {
        return Promise.resolve(pr_url);
      }
      return new Promise(
        (resolve, _reject) => {
          (0, import_providerUtil.disconnectProvider)(pr_url.provider).catch((param) => {
            console.log("Error disconnecting provider=", param.message);
          }).finally(() => {
            resolve(connectProvider(currNet, import_networkState.rpcConfig));
          });
        }
      );
    },
    { provider: void 0, network: void 0 }
  ),
  (0, import_operators.filter)((p_n) => !!p_n.provider && !!p_n.network),
  (0, import_rxjs.map)((p_n) => p_n),
  (0, import_rxjs.distinctUntilChanged)((v1, v2) => v1.network.rpcUrl === v2.network.rpcUrl),
  // TODO check if it's called on last unsubscribe
  finalizeWithValue((n_p) => n_p ? (0, import_providerUtil.disconnectProvider)(n_p.provider) : null),
  (0, import_rxjs.shareReplay)(1)
);
const selectedProvider$ = selectedNetworkProvider$.pipe(
  (0, import_rxjs.map)((n_p) => n_p.provider),
  (0, import_rxjs.shareReplay)(1)
);
const instantProvider$ = selectedProvider$.pipe(
  (0, import_rxjs.startWith)(void 0),
  (0, import_rxjs.shareReplay)(1)
);
function finalizeWithValue(callback) {
  return (source) => (0, import_rxjs.defer)(() => {
    let lastValue;
    return source.pipe(
      (0, import_rxjs.tap)((value) => lastValue = value),
      (0, import_rxjs.finalize)(() => callback(lastValue))
    );
  });
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  instantProvider$,
  providerConnState$,
  selectedNetworkProvider$,
  selectedProvider$
});
