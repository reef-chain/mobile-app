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
var bindUtil_exports = {};
__export(bindUtil_exports, {
  bindEvmAddress: () => bindEvmAddress
});
module.exports = __toCommonJS(bindUtil_exports);
var import_transactionUtil = require("../token/transactionUtil");
const bindEvmAddress = (signer, provider, onTxChange) => {
  if (!provider || !signer || signer?.isEvmClaimed) {
    return "";
  }
  const txIdent = Math.random().toString(10);
  signer.signer.claimDefaultAccount().then(() => {
    if (!onTxChange) {
      alert(
        `Success, Ethereum VM address is ${signer.evmAddress}. Use this address ONLY on Reef chain.`
      );
    } else {
      onTxChange({
        txIdent,
        isInBlock: true,
        addresses: [signer.address]
      });
    }
  }).catch((err) => {
    const errHandler = onTxChange || ((txStat) => alert(txStat.error?.message));
    (0, import_transactionUtil.handleErr)(err, txIdent, "", errHandler, signer);
  });
  return txIdent;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  bindEvmAddress
});
