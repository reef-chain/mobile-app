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
var tokenUtil_exports = {};
__export(tokenUtil_exports, {
  calculateTokenPrice_sdo: () => calculateTokenPrice_sdo,
  createEmptyToken: () => createEmptyToken,
  createEmptyTokenWithAmount: () => createEmptyTokenWithAmount,
  getContractTypeAbi: () => getContractTypeAbi,
  getTokenPrice: () => getTokenPrice,
  isNativeAddress: () => isNativeAddress,
  isNativeTransfer: () => isNativeTransfer,
  normalize: () => normalize,
  reefTokenWithAmount: () => reefTokenWithAmount,
  toCurrencyFormat: () => toCurrencyFormat,
  toTokenAmount: () => toTokenAmount
});
module.exports = __toCommonJS(tokenUtil_exports);
var import_ethers = require("ethers");
var import_bignumber = require("bignumber.js");
var import_tokenModel = require("./tokenModel");
var import_statusDataObject = require("../reefState/model/statusDataObject");
var import_ERC20 = require("./abi/ERC20");
var import_ERC721Uri = require("./abi/ERC721Uri");
var import_ERC1155Uri = require("./abi/ERC1155Uri");
const { parseUnits, formatEther } = import_ethers.utils;
const getReefTokenPoolReserves = (reefTokenPool, reefAddress) => {
  let reefReserve;
  let tokenReserve;
  if (reefTokenPool.token1.address.toLowerCase() === reefAddress.toLowerCase()) {
    reefReserve = parseInt(reefTokenPool.reserve1, 10);
    tokenReserve = parseInt(reefTokenPool.reserve2, 10);
  } else {
    reefReserve = parseInt(reefTokenPool.reserve2, 10);
    tokenReserve = parseInt(reefTokenPool.reserve1, 10);
  }
  return { reefReserve, tokenReserve };
};
const findReefTokenPool_sdo = (pools, reefAddress, token) => pools.find((pool_sdo) => {
  if (!pool_sdo?.data) {
    return false;
  }
  const pool = pool_sdo.data;
  return pool.token1?.address.toLowerCase() === reefAddress.toLowerCase() && pool.token2?.address.toLowerCase() === token.address.toLowerCase() || pool.token2?.address.toLowerCase() === reefAddress.toLowerCase() && pool.token1?.address.toLowerCase() === token.address.toLowerCase();
});
const calculateTokenPrice_sdo = (token, pools, reefPrice) => {
  let ratio;
  if (token.address.toLowerCase() === import_tokenModel.REEF_ADDRESS.toLowerCase()) {
    return reefPrice;
  }
  const reefTokenPool = findReefTokenPool_sdo(pools.data, import_tokenModel.REEF_ADDRESS, token);
  const minStat = (0, import_statusDataObject.findMinStatusCode)([reefTokenPool, reefPrice]);
  if (!reefTokenPool || !reefTokenPool.data || minStat < import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA) {
    if (pools.hasStatus(import_statusDataObject.FeedbackStatusCode.LOADING)) {
      return (0, import_statusDataObject.toFeedbackDM)(0, import_statusDataObject.FeedbackStatusCode.LOADING);
    }
    if (!reefTokenPool || reefTokenPool.hasStatus(import_statusDataObject.FeedbackStatusCode.ERROR)) {
      return (0, import_statusDataObject.toFeedbackDM)(
        0,
        import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
        "Pool not found."
      );
    }
    return (0, import_statusDataObject.toFeedbackDM)(0, minStat);
  }
  const { reefReserve, tokenReserve } = getReefTokenPoolReserves(
    reefTokenPool.data,
    import_tokenModel.REEF_ADDRESS
  );
  ratio = reefReserve / tokenReserve;
  const priceVal = ratio * reefPrice.data;
  return (0, import_statusDataObject.toFeedbackDM)(priceVal, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA);
};
const toCurrencyFormat = (value, options = {}) => Intl.NumberFormat(navigator.language, {
  style: "currency",
  currency: "USD",
  currencyDisplay: "symbol",
  ...options
}).format(value);
const normalize = (amount, decimals) => new import_bignumber.BigNumber(Number.isNaN(amount) ? 0 : amount).div(new import_bignumber.BigNumber(10).pow(decimals));
const getContractTypeAbi = (contractType) => {
  switch (contractType) {
    case import_tokenModel.ContractType.ERC20:
      return import_ERC20.ERC20;
    case import_tokenModel.ContractType.ERC721:
      return import_ERC721Uri.ERC721Uri;
    case import_tokenModel.ContractType.ERC1155:
      return import_ERC1155Uri.ERC1155Uri;
    default:
      return [];
  }
};
const createEmptyToken = () => ({
  name: "Select token",
  address: import_tokenModel.EMPTY_ADDRESS,
  balance: import_ethers.BigNumber.from("0"),
  decimals: -1,
  iconUrl: "",
  symbol: "Select token"
});
const createEmptyTokenWithAmount = () => ({
  ...createEmptyToken(),
  // isEmpty,
  price: 0,
  amount: ""
});
const toTokenAmount = (token, state) => ({
  ...token,
  ...state
  // isEmpty: false,
});
function isNativeTransfer(token) {
  return token.address === import_tokenModel.REEF_ADDRESS;
}
const reefTokenWithAmount = () => toTokenAmount(import_tokenModel.REEF_TOKEN, {
  amount: "",
  index: -1,
  price: 0
});
const getTokenPrice = (address, prices) => new import_bignumber.BigNumber(prices[address] ? prices[address] : 0);
const isNativeAddress = (toAddress) => toAddress.length === 48 && toAddress[0] === "5";
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  calculateTokenPrice_sdo,
  createEmptyToken,
  createEmptyTokenWithAmount,
  getContractTypeAbi,
  getTokenPrice,
  isNativeAddress,
  isNativeTransfer,
  normalize,
  reefTokenWithAmount,
  toCurrencyFormat,
  toTokenAmount
});
