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
var token_exports = {};
__export(token_exports, {
  ContractType: () => import_tokenModel.ContractType,
  EMPTY_ADDRESS: () => import_tokenModel.EMPTY_ADDRESS,
  REEF_ADDRESS: () => import_tokenModel.REEF_ADDRESS,
  REEF_TOKEN: () => import_tokenModel.REEF_TOKEN,
  createEmptyToken: () => import_tokenUtil7.createEmptyToken,
  createEmptyTokenWithAmount: () => import_tokenUtil6.createEmptyTokenWithAmount,
  getContractTypeAbi: () => import_tokenUtil8.getContractTypeAbi,
  getTokenPrice: () => import_tokenUtil2.getTokenPrice,
  isNativeAddress: () => import_tokenUtil.isNativeAddress,
  isNativeTransfer: () => import_tokenUtil4.isNativeTransfer,
  reefPrice$: () => import_reefPrice.reefPrice$,
  reefTokenWithAmount: () => import_tokenUtil3.reefTokenWithAmount,
  toTokenAmount: () => import_tokenUtil5.toTokenAmount
});
module.exports = __toCommonJS(token_exports);
var import_tokenModel = require("./tokenModel");
var import_tokenUtil = require("./tokenUtil");
var import_tokenUtil2 = require("./tokenUtil");
var import_tokenUtil3 = require("./tokenUtil");
var import_tokenUtil4 = require("./tokenUtil");
var import_tokenUtil5 = require("./tokenUtil");
var import_tokenUtil6 = require("./tokenUtil");
var import_tokenUtil7 = require("./tokenUtil");
var import_tokenUtil8 = require("./tokenUtil");
var import_reefPrice = require("./reefPrice");
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ContractType,
  EMPTY_ADDRESS,
  REEF_ADDRESS,
  REEF_TOKEN,
  createEmptyToken,
  createEmptyTokenWithAmount,
  getContractTypeAbi,
  getTokenPrice,
  isNativeAddress,
  isNativeTransfer,
  reefPrice$,
  reefTokenWithAmount,
  toTokenAmount
});
