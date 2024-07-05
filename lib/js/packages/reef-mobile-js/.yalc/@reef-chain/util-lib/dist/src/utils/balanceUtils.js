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
var balanceUtils_exports = {};
__export(balanceUtils_exports, {
  formatDisplayBalance: () => formatDisplayBalance,
  toReefBalanceDisplay: () => import_utils.toReefBalanceDisplay
});
module.exports = __toCommonJS(balanceUtils_exports);
var import_utils = require("./utils");
var import_ethers = require("ethers");
var bigNumber = __toESM(require("bignumber.js"));
const formatHumanAmount = (value = "") => {
  let amount = new bigNumber.BigNumber(value.split(",").join(""));
  let output = "";
  if (amount.isNaN())
    return amount.toString();
  const decPlaces = 100;
  const abbrev = ["k", "M", "B"];
  for (let i = abbrev.length - 1; i >= 0; i -= 1) {
    const size = Math.pow(10, (i + 1) * 3);
    if (amount.isGreaterThanOrEqualTo(size)) {
      amount = amount.times(decPlaces).dividedBy(size).integerValue().dividedBy(decPlaces);
      if (amount.isEqualTo(1e3) && i < abbrev.length - 1) {
        amount = bigNumber.BigNumber(1);
        i += 1;
      }
      output = `${amount.toString()} ${abbrev[i]}`;
      break;
    }
  }
  return output;
};
const toCurrencyFormat = (value) => Intl.NumberFormat("en", {
  style: "currency",
  currency: "USD",
  currencyDisplay: "symbol"
}).format(value);
const defaultTokenDetails = {
  price: 1,
  decimals: 18,
  symbol: ""
};
const formatHumanReadableBalance = (value, tokenDetails) => {
  const _tokenDetails = { ...defaultTokenDetails, ...tokenDetails };
  const balanceValue = new bigNumber.BigNumber(value).div(new bigNumber.BigNumber(10).pow(_tokenDetails.decimals)).multipliedBy(_tokenDetails.price).toNumber();
  const balance = new bigNumber.BigNumber(balanceValue);
  const isSymbol = _tokenDetails.symbol.length > 0;
  if (balance.isNaN())
    return "0";
  if (balance.isGreaterThanOrEqualTo(1e6)) {
    const humanReadableBalance = formatHumanAmount(balance.toString());
    return isSymbol ? `${humanReadableBalance} ${_tokenDetails.symbol}` : `$${humanReadableBalance}`;
  }
  return isSymbol ? `${toCurrencyFormat(balance.toNumber()).split("$")[1]} ${_tokenDetails.symbol}` : toCurrencyFormat(balance.toNumber());
};
const _zeroPadding = (val, num) => {
  while (num - 1 > 0) {
    val = "0" + val;
    num--;
  }
  return val;
};
const _checkIfAllZeroes = (num) => {
  for (var i = 0; i < num.length; i++) {
    if (num[i] != "0")
      return false;
  }
  return true;
};
const _formatDouble = (value) => {
  if (value < 1e3) {
    return value.toFixed(0).toString();
  } else if (value < 1e6) {
    return `${(value / 1e3).toFixed(1)}k`;
  } else if (value < 1e9) {
    return `${(value / 1e6).toFixed(3)}M`;
  } else if (value < 1e12) {
    return `${(value / 1e9).toFixed(3)}B`;
  } else {
    return `${(value / 1e12).toFixed(3)}T`;
  }
};
const formatDisplayBalance = (val, fraction = 4, tokenDetails) => {
  const threshold = import_ethers.BigNumber.from("1000000000000000000");
  if (tokenDetails && typeof val == "string") {
    return formatHumanReadableBalance(val, tokenDetails);
  }
  if (val.lt(threshold)) {
    var zeroPadding = _zeroPadding(
      val.toString(),
      18 - val.toString().length
    ).substring(0, fraction);
    if (_checkIfAllZeroes(zeroPadding)) {
      zeroPadding = `${zeroPadding.substring(0, fraction - 1)}1`;
    }
    return `0.${zeroPadding}`;
  }
  const balance = val.div(threshold);
  return `${_formatDouble(balance.toNumber())}`;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  formatDisplayBalance,
  toReefBalanceDisplay
});
