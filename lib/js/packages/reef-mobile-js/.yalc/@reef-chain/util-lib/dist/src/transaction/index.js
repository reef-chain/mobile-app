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
var transaction_exports = {};
__export(transaction_exports, {
  TX_STATUS_ERROR_CODE: () => import_txErrorUtil.TX_STATUS_ERROR_CODE,
  TxStage: () => import_transaction_model.TxStage,
  decodePayloadMethod: () => import_tx_signature_util.decodePayloadMethod,
  getEvmTransactionStatus$: () => import_transaction_status_util.getEvmTransactionStatus$,
  nativeTransfer$: () => import_token_transfer_util.nativeTransfer$,
  nativeTransferSigner$: () => import_token_transfer_util.nativeTransferSigner$,
  reef20Transfer$: () => import_token_transfer_util.reef20Transfer$
});
module.exports = __toCommonJS(transaction_exports);
var import_token_transfer_util = require("./token-transfer-util");
var import_txErrorUtil = require("./txErrorUtil");
var import_transaction_status_util = require("./transaction-status-util");
var import_tx_signature_util = require("../signature/tx-signature-util");
var import_transaction_model = require("./transaction-model");
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TX_STATUS_ERROR_CODE,
  TxStage,
  decodePayloadMethod,
  getEvmTransactionStatus$,
  nativeTransfer$,
  nativeTransferSigner$,
  reef20Transfer$
});
