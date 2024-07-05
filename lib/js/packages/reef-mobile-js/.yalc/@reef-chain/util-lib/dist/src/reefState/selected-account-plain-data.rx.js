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
var selected_account_plain_data_rx_exports = {};
__export(selected_account_plain_data_rx_exports, {
  accounts$: () => accounts$,
  selectedAccount$: () => selectedAccount$,
  selectedNFTs$: () => selectedNFTs$,
  selectedTokenBalances$: () => selectedTokenBalances$,
  selectedTokenPrices$: () => selectedTokenPrices$,
  selectedTransactionHistory$: () => selectedTransactionHistory$
});
module.exports = __toCommonJS(selected_account_plain_data_rx_exports);
var import_rxjs = require("rxjs");
var import_tokenState = require("./tokenState.rx");
var import_accounts = require("./account/accounts");
var import_statusDataObject = require("./model/statusDataObject");
var import_selectedAccount = require("./account/selectedAccount");
const accounts$ = unwrapSDOArray(import_accounts.accounts_status$);
const selectedAccount$ = unwrapSDO(import_selectedAccount.selectedAccount_status$);
const selectedTokenBalances$ = unwrapSDOArray(import_tokenState.selectedTokenBalances_status$);
const selectedNFTs$ = unwrapSDOArray(import_tokenState.selectedNFTs_status$);
const selectedTokenPrices$ = unwrapSDOArray(import_tokenState.selectedTokenPrices_status$);
const selectedTransactionHistory$ = unwrapSDO(import_tokenState.selectedTransactionHistory_status$);
function unwrapSDO(sdoObservable) {
  return sdoObservable.pipe(
    (0, import_rxjs.map)((res) => {
      if (!res) {
        return void 0;
      }
      if (res.hasStatus(import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)) {
        return res.data;
      }
      if ((0, import_statusDataObject.findMinStatusCode)([res]) < import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES) {
        return void 0;
      }
      return null;
    }),
    (0, import_rxjs.distinctUntilChanged)(),
    (0, import_rxjs.shareReplay)(1)
  );
}
function unwrapSDOArray(sdoObservable) {
  return sdoObservable.pipe(
    (0, import_rxjs.map)((res) => {
      if (res.hasStatus(import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)) {
        return res.data.map((a) => a.data);
      }
      if ((0, import_statusDataObject.findMinStatusCode)(res.data) < import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES) {
        return void 0;
      }
      return null;
    }),
    (0, import_rxjs.distinctUntilChanged)(),
    (0, import_rxjs.shareReplay)(1)
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accounts$,
  selectedAccount$,
  selectedNFTs$,
  selectedTokenBalances$,
  selectedTokenPrices$,
  selectedTransactionHistory$
});
