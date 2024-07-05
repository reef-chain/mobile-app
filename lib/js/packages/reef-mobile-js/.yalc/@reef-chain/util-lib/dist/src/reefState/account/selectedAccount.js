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
var selectedAccount_exports = {};
__export(selectedAccount_exports, {
  selectedAccount_status$: () => selectedAccount_status$,
  selectedAddress$: () => selectedAddress$
});
module.exports = __toCommonJS(selectedAccount_exports);
var import_rxjs = require("rxjs");
var import_accounts = require("./accounts");
var import_setAccounts = require("./setAccounts");
var import_statusDataObject = require("../model/statusDataObject");
const selectedAddress$ = import_setAccounts.selectedAddressSubj.asObservable().pipe((0, import_rxjs.startWith)(void 0), (0, import_rxjs.distinctUntilChanged)(), (0, import_rxjs.shareReplay)(1));
(0, import_rxjs.combineLatest)([import_accounts.accounts_status$, selectedAddress$]).pipe((0, import_rxjs.take)(1)).subscribe(
  ([signers, address]) => {
    let saved = address;
    try {
      if (!saved) {
        saved = localStorage?.getItem("selected_address_reef") || void 0;
      }
    } catch (e) {
    }
    if (!saved) {
      const firstSigner = signers && signers.data && signers.data[0] ? signers.data[0].data : void 0;
      (0, import_setAccounts.setSelectedAddress)(saved || firstSigner?.address);
    }
  }
);
const selectedAccount_status$ = (0, import_rxjs.combineLatest)([selectedAddress$, import_accounts.accounts_status$]).pipe(
  (0, import_rxjs.map)(
    (selectedAddressAndSigners) => {
      const [selectedAddress, signers] = selectedAddressAndSigners;
      if (!selectedAddress || !signers || !signers.data?.length) {
        return void 0;
      }
      let foundSigner = signers.data.find(
        (signer) => signer.data.address === selectedAddress
      );
      if (!foundSigner) {
        foundSigner = signers && signers.data ? signers.data[0] : void 0;
      }
      try {
        if (foundSigner) {
          localStorage.setItem(
            "selected_address_reef",
            foundSigner.data.address || ""
          );
        }
      } catch (e) {
      }
      return foundSigner ? (0, import_statusDataObject.toFeedbackDM)(
        { ...foundSigner.data },
        foundSigner.getStatusList()
      ) : void 0;
    }
  ),
  (0, import_rxjs.catchError)((err) => {
    console.log("selectedAccount_status$ ERROR=", err.message);
    return (0, import_rxjs.of)(void 0);
  }),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  selectedAccount_status$,
  selectedAddress$
});
