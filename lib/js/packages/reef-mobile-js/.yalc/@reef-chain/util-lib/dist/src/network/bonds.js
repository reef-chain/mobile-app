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
var bonds_exports = {};
__export(bonds_exports, {
  bonds: () => bonds
});
module.exports = __toCommonJS(bonds_exports);
var import_token = require("../token");
const bondsMainnet = [
  {
    name: "Reef community staking bond",
    description: "",
    contractAddress: "0x7D3596b724cEB02f2669b902E4F1EEDeEfad3be6",
    validatorAddress: "5Hax9GZjpurht2RpDr5eNLKvEApECuNxUpmRbYs5iNh7LpHa",
    stake: { ...import_token.REEF_TOKEN },
    farm: { ...import_token.REEF_TOKEN },
    apy: "32"
  }
];
const bonds = {
  mainnet: bondsMainnet,
  testnet: [],
  localhost: []
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  bonds
});
