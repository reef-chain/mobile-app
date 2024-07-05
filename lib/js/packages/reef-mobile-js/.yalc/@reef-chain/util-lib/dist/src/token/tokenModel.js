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
var tokenModel_exports = {};
__export(tokenModel_exports, {
  ContractType: () => ContractType,
  EMPTY_ADDRESS: () => EMPTY_ADDRESS,
  REEF_ADDRESS: () => REEF_ADDRESS,
  REEF_TOKEN: () => REEF_TOKEN
});
module.exports = __toCommonJS(tokenModel_exports);
var import_ethers = require("ethers");
const REEF_ADDRESS = "0x0000000000000000000000000000000001000000";
const REEF_TOKEN = {
  name: "REEF",
  address: REEF_ADDRESS,
  iconUrl: "https://storage.googleapis.com/reef-static-images/r-circle-icon-128.png",
  balance: import_ethers.BigNumber.from(0),
  decimals: 18,
  symbol: "REEF"
};
const EMPTY_ADDRESS = "0x0000000000000000000000000000000000000000";
var ContractType = /* @__PURE__ */ ((ContractType2) => {
  ContractType2["ERC20"] = "ERC20";
  ContractType2["ERC721"] = "ERC721";
  ContractType2["ERC1155"] = "ERC1155";
  ContractType2["other"] = "other";
  return ContractType2;
})(ContractType || {});
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ContractType,
  EMPTY_ADDRESS,
  REEF_ADDRESS,
  REEF_TOKEN
});
