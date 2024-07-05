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
var setAccounts_exports = {};
__export(setAccounts_exports, {
  accountsJsonSigningKeySubj: () => accountsJsonSigningKeySubj,
  accountsJsonSubj: () => accountsJsonSubj,
  selectedAddressSubj: () => selectedAddressSubj,
  setAccounts: () => setAccounts,
  setSelectedAddress: () => setSelectedAddress,
  updateSignersSubj: () => updateSignersSubj
});
module.exports = __toCommonJS(setAccounts_exports);
var import_rxjs = require("rxjs");
const accountsJsonSubj = new import_rxjs.ReplaySubject(1);
const accountsJsonSigningKeySubj = new import_rxjs.BehaviorSubject(null);
const updateSignersSubj = new import_rxjs.Subject();
const setAccounts = (accounts) => accountsJsonSubj.next(accounts);
const selectedAddressSubj = new import_rxjs.Subject();
const setSelectedAddress = (address) => selectedAddressSubj.next(address);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accountsJsonSigningKeySubj,
  accountsJsonSubj,
  selectedAddressSubj,
  setAccounts,
  setSelectedAddress,
  updateSignersSubj
});
