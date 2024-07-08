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
var latestBlockModel_exports = {};
__export(latestBlockModel_exports, {
  AccountIndexedTransactionType: () => AccountIndexedTransactionType,
  allIndexedTransactions: () => allIndexedTransactions
});
module.exports = __toCommonJS(latestBlockModel_exports);
var AccountIndexedTransactionType = /* @__PURE__ */ ((AccountIndexedTransactionType2) => {
  AccountIndexedTransactionType2[AccountIndexedTransactionType2["REEF20_TRANSFER"] = 0] = "REEF20_TRANSFER";
  AccountIndexedTransactionType2[AccountIndexedTransactionType2["REEF_NFT_TRANSFER"] = 1] = "REEF_NFT_TRANSFER";
  AccountIndexedTransactionType2[AccountIndexedTransactionType2["REEF_BIND_TX"] = 2] = "REEF_BIND_TX";
  return AccountIndexedTransactionType2;
})(AccountIndexedTransactionType || {});
const allIndexedTransactions = [
  2 /* REEF_BIND_TX */,
  1 /* REEF_NFT_TRANSFER */,
  0 /* REEF20_TRANSFER */
];
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  AccountIndexedTransactionType,
  allIndexedTransactions
});
