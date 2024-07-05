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
var selectedAccountAddressChange_exports = {};
__export(selectedAccountAddressChange_exports, {
  selectedAccountAddressChange$: () => selectedAccountAddressChange$
});
module.exports = __toCommonJS(selectedAccountAddressChange_exports);
var import_selectedAccount = require("./selectedAccount");
var import_operators = require("rxjs/operators");
var import_rxjs = require("rxjs");
const selectedAccountAddressChange$ = import_selectedAccount.selectedAccount_status$.pipe(
  (0, import_operators.filter)((v) => !!v),
  (0, import_rxjs.distinctUntilChanged)((s1, s2) => s1.data.address === s2.data.address),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  selectedAccountAddressChange$
});
