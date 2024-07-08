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
var accounts_exports = {};
__export(accounts_exports, {
  accounts_status$: () => accounts_status$,
  toInjectedAccountsWithMeta: () => toInjectedAccountsWithMeta
});
module.exports = __toCommonJS(accounts_exports);
var import_accountsIndexedData = require("./accountsIndexedData");
var import_extension = require("../../extension");
const accounts_status$ = import_accountsIndexedData.accountsWithUpdatedIndexedData$;
const toInjectedAccountsWithMeta = (injAccounts, extensionSourceName = import_extension.REEF_EXTENSION_IDENT) => {
  return injAccounts.map(
    (acc) => ({
      address: acc.address,
      meta: {
        name: acc.name,
        source: extensionSourceName
      }
    })
  );
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accounts_status$,
  toInjectedAccountsWithMeta
});
