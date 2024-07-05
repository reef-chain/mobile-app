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
var ws_connection_state_exports = {};
__export(ws_connection_state_exports, {
  getCollectedWsStateValue$: () => getCollectedWsStateValue$
});
module.exports = __toCommonJS(ws_connection_state_exports);
var import_rxjs = require("rxjs");
function getCollectedWsStateValue$(fromSubj) {
  return fromSubj.pipe(
    (0, import_rxjs.scan)(
      (state, curr) => {
        if (curr.status.value === "error") {
          return {
            isConnected: curr.isConnected,
            status: curr.status,
            lastErr: curr.status
          };
        }
        return {
          isConnected: curr.isConnected,
          status: curr.status,
          lastErr: state.lastErr
        };
      },
      {
        isConnected: false,
        status: { value: "disconnected", timestamp: (/* @__PURE__ */ new Date()).getTime() }
      }
    ),
    (0, import_rxjs.startWith)({
      isConnected: false,
      status: { value: "disconnected", timestamp: (/* @__PURE__ */ new Date()).getTime() }
    }),
    (0, import_rxjs.shareReplay)(1)
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getCollectedWsStateValue$
});
