var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
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
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var prices_exports = {};
__export(prices_exports, {
  PRICE_REEF_TOKEN_ID: () => PRICE_REEF_TOKEN_ID,
  getTokenEthAddressListPrices: () => getTokenEthAddressListPrices,
  getTokenListPrices: () => getTokenListPrices,
  getTokenPrice: () => getTokenPrice,
  retrieveReefCoingeckoPrice: () => retrieveReefCoingeckoPrice
});
module.exports = __toCommonJS(prices_exports);
var import_axios = __toESM(require("axios"));
const PRICE_REEF_TOKEN_ID = "reef";
const coingeckoApi = import_axios.default.create({
  baseURL: "https://api.coingecko.com/api/v3/"
});
const explorerApi = import_axios.default.create({
  baseURL: "https://api.reefscan.com"
});
const getCoingeckoPrice = (tokenId) => coingeckoApi.get(
  `/simple/price?ids=${tokenId}&vs_currencies=usd`
).then((res) => res.data[tokenId].usd);
const getTokenPrice = async (tokenId) => {
  if (tokenId === PRICE_REEF_TOKEN_ID) {
    return explorerApi.get("/price/reef").then((res) => res.data.usd).catch(() => getCoingeckoPrice(tokenId));
  }
  return getCoingeckoPrice(tokenId);
};
const getTokenListPrices = async (tokenIds) => coingeckoApi.get(
  `/simple/price?ids=${tokenIds.join(",")}&vs_currencies=usd`
).then(
  (res) => tokenIds.reduce((tknPrices, currTknId) => {
    if (res.data[currTknId]) {
      tknPrices[currTknId] = res.data[currTknId].usd;
    }
    return tknPrices;
  }, {})
);
const getTokenEthAddressListPrices = async (tokenAddressList) => coingeckoApi.get(
  `/simple/price?contract_addresses=${tokenAddressList.join(
    ","
  )}&vs_currencies=usd`
).then(
  (res) => tokenAddressList.reduce((tknPrices, currTknId) => {
    if (res.data[currTknId]) {
      tknPrices[currTknId] = res.data[currTknId].usd;
    }
    return tknPrices;
  }, {})
);
const retrieveReefCoingeckoPrice = async () => getTokenPrice(PRICE_REEF_TOKEN_ID);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  PRICE_REEF_TOKEN_ID,
  getTokenEthAddressListPrices,
  getTokenListPrices,
  getTokenPrice,
  retrieveReefCoingeckoPrice
});
