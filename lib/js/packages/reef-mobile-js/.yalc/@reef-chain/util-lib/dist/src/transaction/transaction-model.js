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
var transaction_model_exports = {};
__export(transaction_model_exports, {
  TxStage: () => TxStage
});
module.exports = __toCommonJS(transaction_model_exports);
var TxStage = /* @__PURE__ */ ((TxStage2) => {
  TxStage2["SIGNATURE_REQUEST"] = "SIGNATURE_REQUEST";
  TxStage2["SIGNED"] = "SIGNED";
  TxStage2["BROADCAST"] = "BROADCAST";
  TxStage2["INCLUDED_IN_BLOCK"] = "INCLUDED_IN_BLOCK";
  TxStage2["BLOCK_FINALIZED"] = "BLOCK_FINALIZED";
  TxStage2["BLOCK_NOT_FINALIZED"] = "BLOCK_NOT_FINALIZED";
  TxStage2["ENDED"] = "ENDED";
  return TxStage2;
})(TxStage || {});
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TxStage
});
