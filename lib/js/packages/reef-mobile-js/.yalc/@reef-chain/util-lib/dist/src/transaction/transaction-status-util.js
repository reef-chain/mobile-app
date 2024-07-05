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
var transaction_status_util_exports = {};
__export(transaction_status_util_exports, {
  TxStatusError: () => TxStatusError,
  getEvmTransactionStatus$: () => getEvmTransactionStatus$,
  getNativeTransactionStatusHandler$: () => getNativeTransactionStatusHandler$,
  parseAndRethrowErrorFromObserver: () => parseAndRethrowErrorFromObserver
});
module.exports = __toCommonJS(transaction_status_util_exports);
var import_rxjs = require("rxjs");
var import_operators = require("rxjs/operators");
var import_txErrorUtil = require("./txErrorUtil");
var import_pendingTx = require("../reefState/tx/pendingTx.rx");
var import_transaction_model = require("./transaction-model");
function parseAndRethrowErrorFromObserver(observer, txIdent) {
  return (err) => {
    const parsedErr = (0, import_txErrorUtil.toTxErrorCodeValue)(err);
    let reError = !!parsedErr.code && parsedErr.code != import_txErrorUtil.TX_STATUS_ERROR_CODE.ERROR_UNDEFINED ? new Error(parsedErr.code) : err;
    observer.error(new TxStatusError(reError.message, txIdent));
  };
}
function getEvmTransactionStatus$(evmTxPromise, rpcApi, txIdent) {
  const status$ = new import_rxjs.Observable((observer) => {
    evmTxPromise.then((tx) => {
      observer.next({
        txStage: import_transaction_model.TxStage.BROADCAST,
        txData: tx,
        txIdent
      });
      tx.wait().then(async (receipt) => {
        observer.next({
          txStage: import_transaction_model.TxStage.INCLUDED_IN_BLOCK,
          txData: receipt,
          txIdent
        });
        let count = 10;
        const finalizedCount = -111;
        const unsubHeads = await rpcApi.rpc.chain.subscribeFinalizedHeads(
          (lastHeader) => {
            if (receipt.blockHash.toString() === lastHeader.hash.toString()) {
              observer.next({
                txIdent,
                txStage: import_transaction_model.TxStage.BLOCK_FINALIZED,
                txData: receipt
              });
              count = finalizedCount;
            }
            if (--count < 0) {
              if (count > finalizedCount) {
                observer.next({
                  txIdent,
                  txStage: import_transaction_model.TxStage.BLOCK_NOT_FINALIZED,
                  txData: receipt
                });
              }
              unsubHeads();
              observer.complete();
            }
          }
        );
      }).catch((err) => {
        console.log("transfer tx.wait ERROR=", err.message);
        observer.error(new TxStatusError(err.message, txIdent));
      });
    }).catch(parseAndRethrowErrorFromObserver(observer, txIdent));
  }).pipe(
    // @ts-ignore
    (0, import_operators.shareReplay)(1)
  );
  import_pendingTx.attachPendingTxObservableSubj.next(status$);
  return status$;
}
function getNativeTransactionStatusHandler$(txIdent) {
  const observer = new import_rxjs.Subject();
  return {
    handler: (result) => {
      if (result.status.isBroadcast) {
        observer.next({ txStage: import_transaction_model.TxStage.BROADCAST, txIdent });
      } else if (result.status.isInBlock) {
        console.log(
          `Transaction included at blockHash ${result.status.asInBlock}`
        );
        observer.next({
          txStage: import_transaction_model.TxStage.INCLUDED_IN_BLOCK,
          txData: { blockHash: result.status.asInBlock.toString() },
          txIdent
        });
      } else if (result.status.isFinalized) {
        console.log(
          `Transaction finalized at blockHash ${result.status.asFinalized}`
        );
        observer.next({
          txStage: import_transaction_model.TxStage.BLOCK_FINALIZED,
          txData: { blockHash: result.status.asFinalized.toString() },
          txIdent
        });
        setTimeout(() => {
          observer.complete();
        });
      }
    },
    status$: observer
  };
}
class TxStatusError extends Error {
  constructor(message, txIdent) {
    super();
    this.txIdent = txIdent;
    this.message = message;
  }
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TxStatusError,
  getEvmTransactionStatus$,
  getNativeTransactionStatusHandler$,
  parseAndRethrowErrorFromObserver
});
