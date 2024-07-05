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
var txErrorUtil_exports = {};
__export(txErrorUtil_exports, {
  TX_STATUS_ERROR_CODE: () => TX_STATUS_ERROR_CODE,
  toTxErrorCodeValue: () => toTxErrorCodeValue
});
module.exports = __toCommonJS(txErrorUtil_exports);
var TX_STATUS_ERROR_CODE = /* @__PURE__ */ ((TX_STATUS_ERROR_CODE2) => {
  TX_STATUS_ERROR_CODE2["ERROR_MIN_BALANCE_AFTER_TX"] = "ERROR_MIN_BALANCE_AFTER_TX";
  TX_STATUS_ERROR_CODE2["ERROR_BALANCE_TOO_LOW"] = "ERROR_BALANCE_TOO_LOW";
  TX_STATUS_ERROR_CODE2["ERROR_UNDEFINED"] = "ERROR_UNDEFINED";
  TX_STATUS_ERROR_CODE2["CANCELED"] = "CANCELED";
  return TX_STATUS_ERROR_CODE2;
})(TX_STATUS_ERROR_CODE || {});
function toTxErrorCodeValue(e) {
  let message = e.message || e;
  let code = "ERROR_UNDEFINED" /* ERROR_UNDEFINED */;
  if (message && (message.indexOf("-32603: execution revert: 0x") > -1 || message?.indexOf("InsufficientBalance") > -1)) {
    message = "You must allow minimum 60 REEF on account for Ethereum VM transaction even if transaction fees will be much lower.";
    code = "ERROR_MIN_BALANCE_AFTER_TX" /* ERROR_MIN_BALANCE_AFTER_TX */;
  }
  if (message && message?.startsWith("1010")) {
    message = "Balance too low.";
    code = "ERROR_BALANCE_TOO_LOW" /* ERROR_BALANCE_TOO_LOW */;
  }
  if (message && (message === "_canceled" || message === "canceled")) {
    message = "Canceled";
    code = "CANCELED" /* CANCELED */;
  }
  if (message && message?.startsWith("balances.InsufficientBalance")) {
    message = "Balance too low for transfer and fees.";
    code = "ERROR_BALANCE_TOO_LOW" /* ERROR_BALANCE_TOO_LOW */;
  }
  if (code === "ERROR_UNDEFINED" /* ERROR_UNDEFINED */) {
    message = `Transaction error: ${message}`;
  }
  return { message, code };
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TX_STATUS_ERROR_CODE,
  toTxErrorCodeValue
});
