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
var force_reload_tokens_exports = {};
__export(force_reload_tokens_exports, {
  forceReload$: () => forceReload$,
  reloadTokens: () => reloadTokens
});
module.exports = __toCommonJS(force_reload_tokens_exports);
var import_rxjs = require("rxjs");
const reloadTokens = () => {
  forceTokenValuesReloadSubj.next(true);
  console.log("force lib reload tokens");
};
const forceTokenValuesReloadSubj = new import_rxjs.Subject();
const forceReload$ = forceTokenValuesReloadSubj.pipe((0, import_rxjs.startWith)(true));
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  forceReload$,
  reloadTokens
});
