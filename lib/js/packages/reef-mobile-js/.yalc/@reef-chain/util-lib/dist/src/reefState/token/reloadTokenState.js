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
var reloadTokenState_exports = {};
__export(reloadTokenState_exports, {
  selectedAccountAnyBalanceUpdate$: () => selectedAccountAnyBalanceUpdate$,
  selectedAccountFtBalanceUpdate$: () => selectedAccountFtBalanceUpdate$,
  selectedAccountNftBalanceUpdate$: () => selectedAccountNftBalanceUpdate$
});
module.exports = __toCommonJS(reloadTokenState_exports);
var import_rxjs = require("rxjs");
var import_selectedAccountAddressChange = require("../account/selectedAccountAddressChange");
var import_latestBlock = require("../latestBlock");
var import_latestBlockModel = require("../latestBlockModel");
const selectedAccountFtBalanceUpdate$ = import_selectedAccountAddressChange.selectedAccountAddressChange$.pipe(
  (0, import_rxjs.switchMap)(
    (addr) => (0, import_latestBlock.getLatestBlockAccountUpdates$)(
      [addr.data.address],
      [import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER]
    )
  ),
  (0, import_rxjs.map)(() => true),
  (0, import_rxjs.share)()
);
const selectedAccountNftBalanceUpdate$ = import_selectedAccountAddressChange.selectedAccountAddressChange$.pipe(
  (0, import_rxjs.switchMap)(
    (addr) => (0, import_latestBlock.getLatestBlockAccountUpdates$)(
      [addr.data.address],
      [import_latestBlockModel.AccountIndexedTransactionType.REEF_NFT_TRANSFER]
    )
  ),
  (0, import_rxjs.map)(() => true),
  (0, import_rxjs.share)()
);
const selectedAccountAnyBalanceUpdate$ = import_selectedAccountAddressChange.selectedAccountAddressChange$.pipe(
  (0, import_rxjs.switchMap)(
    (addr) => (0, import_latestBlock.getLatestBlockAccountUpdates$)(
      [addr.data.address],
      [
        import_latestBlockModel.AccountIndexedTransactionType.REEF_NFT_TRANSFER,
        import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER
      ]
    )
  ),
  (0, import_rxjs.map)(() => true),
  (0, import_rxjs.share)()
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  selectedAccountAnyBalanceUpdate$,
  selectedAccountFtBalanceUpdate$,
  selectedAccountNftBalanceUpdate$
});
