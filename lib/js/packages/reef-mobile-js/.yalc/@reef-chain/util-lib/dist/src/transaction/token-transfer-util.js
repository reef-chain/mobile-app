var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from2, except, desc) => {
  if (from2 && typeof from2 === "object" || typeof from2 === "function") {
    for (let key of __getOwnPropNames(from2))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from2[key], enumerable: !(desc = __getOwnPropDesc(from2, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var token_transfer_util_exports = {};
__export(token_transfer_util_exports, {
  nativeTransfer$: () => nativeTransfer$,
  nativeTransferSigner$: () => nativeTransferSigner$,
  reef20Transfer$: () => reef20Transfer$
});
module.exports = __toCommonJS(token_transfer_util_exports);
var import_transaction_status_util = require("./transaction-status-util");
var import_rxjs = require("rxjs");
var import_ethers = require("ethers");
var import_addressUtil = require("../account/addressUtil");
var import_txErrorUtil = require("./txErrorUtil");
var import_pendingTx = require("../reefState/tx/pendingTx.rx");
var import_transaction_model = require("./transaction-model");
function nativeTransferSigner$(amount, signer, toAddress) {
  return (0, import_rxjs.from)(signer.getSubstrateAddress()).pipe(
    (0, import_rxjs.switchMap)(
      (fromAddr) => nativeTransfer$(
        amount,
        fromAddr,
        toAddress,
        signer.provider,
        signer.signingKey
      )
    )
  );
}
function nativeTransfer$(amount, fromAddress, toAddress, provider, signingKey, txIdent = Math.random().toString()) {
  const { status$, handler } = (0, import_transaction_status_util.getNativeTransactionStatusHandler$)(txIdent);
  import_pendingTx.addPendingTransactionSubj.next({
    txIdent,
    txStage: import_transaction_model.TxStage.SIGNATURE_REQUEST
  });
  provider.api.query.system.account(fromAddress).then((res) => {
    let fromBalance = res.data.free.toString();
    if (import_ethers.BigNumber.from(amount).gte(fromBalance)) {
      let error = new Error(import_txErrorUtil.TX_STATUS_ERROR_CODE.ERROR_BALANCE_TOO_LOW);
      status$.error({ error, txIdent });
      return;
    }
    provider.api.tx.balances.transfer(toAddress, amount).signAndSend(fromAddress, { signer: signingKey }, handler).then((unsub) => {
      status$.subscribe(null, null, () => unsub());
    }).catch((0, import_transaction_status_util.parseAndRethrowErrorFromObserver)(status$, txIdent));
  });
  import_pendingTx.attachPendingTxObservableSubj.next(status$);
  return status$.asObservable();
}
function reef20Transfer$(to, provider, tokenAmount, tokenContract, txIdent = Math.random().toString()) {
  const STORAGE_LIMIT = 2e3;
  return (0, import_rxjs.of)(to).pipe(
    (0, import_rxjs.switchMap)(async (toAddress) => {
      const toAddr = toAddress.length === 48 ? await (0, import_addressUtil.getEvmAddress)(toAddress, provider) : toAddress;
      return [toAddr, tokenAmount];
    }),
    (0, import_rxjs.switchMap)((ARGS) => {
      import_pendingTx.addPendingTransactionSubj.next({
        txIdent,
        txStage: import_transaction_model.TxStage.SIGNATURE_REQUEST
      });
      const txPromise = tokenContract.transfer(...ARGS, {
        customData: {
          storageLimit: STORAGE_LIMIT,
          txIdent
        }
      });
      return (0, import_transaction_status_util.getEvmTransactionStatus$)(txPromise, provider.api, txIdent);
    })
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  nativeTransfer$,
  nativeTransferSigner$,
  reef20Transfer$
});
