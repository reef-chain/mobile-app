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
var pendingTx_rx_exports = {};
__export(pendingTx_rx_exports, {
  addPendingTransactionSubj: () => addPendingTransactionSubj,
  attachPendingTxObservableSubj: () => attachPendingTxObservableSubj,
  pendingTxList$: () => pendingTxList$
});
module.exports = __toCommonJS(pendingTx_rx_exports);
var import_rxjs = require("rxjs");
var import_merge = require("rxjs/internal/operators/merge");
var import_transaction_model = require("../../transaction/transaction-model");
const addPendingTransactionSubj = new import_rxjs.Subject();
const attachPendingTxObservableSubj = new import_rxjs.Subject();
const pendingTxList$ = attachPendingTxObservableSubj.pipe(
  (0, import_rxjs.mergeMap)((status$) => status$),
  (0, import_merge.merge)(addPendingTransactionSubj),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERRRRRR", err);
    return (0, import_rxjs.of)({
      txIdent: err.txIdent,
      txStage: import_transaction_model.TxStage.ENDED
    });
  }),
  (0, import_rxjs.scan)(
    (statById, newState) => {
      if (newState.txStage == import_transaction_model.TxStage.BLOCK_NOT_FINALIZED || newState.txStage == import_transaction_model.TxStage.BLOCK_FINALIZED || newState.txStage == import_transaction_model.TxStage.ENDED) {
        statById.delete(newState.txIdent);
        return statById;
      }
      statById.set(newState.txIdent, newState);
      return statById;
    },
    /* @__PURE__ */ new Map()
  ),
  (0, import_rxjs.tap)((v) => console.log("new list", Array.from(v.keys()).length)),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  addPendingTransactionSubj,
  attachPendingTxObservableSubj,
  pendingTxList$
});
