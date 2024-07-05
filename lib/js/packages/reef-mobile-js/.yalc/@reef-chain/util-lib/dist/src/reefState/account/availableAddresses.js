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
var availableAddresses_exports = {};
__export(availableAddresses_exports, {
  availableAddresses$: () => availableAddresses$
});
module.exports = __toCommonJS(availableAddresses_exports);
var import_setAccounts = require("./setAccounts");
var import_extension = require("../../extension");
var import_rxjs = require("rxjs");
var import_operators = require("rxjs/operators");
const availableAddresses$ = import_setAccounts.accountsJsonSubj.pipe(
  (0, import_operators.filter)((v) => !!v),
  (0, import_rxjs.map)(
    (acc) => acc.map((a) => {
      let source = a.meta?.source || a.source;
      if (!source) {
        source = import_extension.REEF_EXTENSION_IDENT;
        console.log("No extension source set for account=", a);
      }
      let meta = a.meta ? a.meta : { source };
      return { address: a.address, ...meta };
    })
  ),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  availableAddresses$
});
