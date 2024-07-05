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
var math_exports = {};
__export(math_exports, {
  assertAmount: () => assertAmount,
  calculateAmount: () => calculateAmount,
  calculateAmountWithPercentage: () => calculateAmountWithPercentage,
  calculateBalance: () => calculateBalance,
  calculateDeadline: () => calculateDeadline,
  calculateImpactPercentage: () => calculateImpactPercentage,
  calculatePoolRatio: () => calculatePoolRatio,
  calculatePoolShare: () => calculatePoolShare,
  calculatePoolSupply: () => calculatePoolSupply,
  calculateUsdAmount: () => calculateUsdAmount,
  checkMinExistentialReefAmount: () => checkMinExistentialReefAmount,
  convert2Normal: () => convert2Normal,
  convertAmount: () => convertAmount,
  ensureAmount: () => ensureAmount,
  ensureExistentialReefAmount: () => ensureExistentialReefAmount,
  ensureTokenAmount: () => ensureTokenAmount,
  exponentNrSplit: () => exponentNrSplit,
  formatAmount: () => formatAmount,
  getHashSumLastNr: () => getHashSumLastNr,
  getInputAmount: () => getInputAmount,
  getOutputAmount: () => getOutputAmount,
  mean: () => mean,
  minimumRecieveAmount: () => minimumRecieveAmount,
  noExponents: () => noExponents,
  poolRatio: () => poolRatio,
  removePoolTokenShare: () => removePoolTokenShare,
  removeSupply: () => removeSupply,
  removeUserPoolSupply: () => removeUserPoolSupply,
  showBalance: () => showBalance,
  showRemovePoolTokenShare: () => showRemovePoolTokenShare,
  std: () => std,
  toBalance: () => toBalance,
  toDecimalPlaces: () => toDecimalPlaces,
  toHumanAmount: () => toHumanAmount,
  toUnits: () => toUnits,
  transformAmount: () => transformAmount,
  variance: () => variance
});
module.exports = __toCommonJS(math_exports);
var import_ethers = require("ethers");
var import_tokenModel = require("../token/tokenModel");
var import_utils = require("ethers/lib/utils");
var import_tokenUtil = require("../token/tokenUtil");
var import_utils2 = require("./utils");
const findDecimalPoint = (amount) => {
  const { length } = amount;
  let index = amount.indexOf(",");
  if (index !== -1) {
    return length - index - 1;
  }
  index = amount.indexOf(".");
  if (index !== -1) {
    return length - index - 1;
  }
  return 0;
};
const transformAmount = (decimals, amount) => {
  if (!amount) {
    return "0".repeat(decimals);
  }
  const addZeros = findDecimalPoint(amount);
  const cleanedAmount = amount.split(",").join("").split(".").join("");
  return cleanedAmount + "0".repeat(Math.max(decimals - addZeros, 0));
};
const assertAmount = (amount) => !amount ? "0" : amount;
const convert2Normal = (decimals, inputAmount) => {
  const amount = "0".repeat(decimals + 4) + assertAmount(inputAmount);
  const pointer = amount.length - decimals;
  const decimalPointer = `${amount.slice(0, pointer)}.${amount.slice(
    pointer,
    amount.length
  )}`;
  return parseFloat(decimalPointer);
};
const calculateAmount = ({
  decimals,
  amount
}) => import_ethers.BigNumber.from(transformAmount(decimals, assertAmount(amount))).toString();
const calculateAmountWithPercentage = ({ amount: oldAmount, decimals }, percentage) => {
  if (!oldAmount) {
    return "0";
  }
  const amount = parseFloat(assertAmount(oldAmount)) * (1 - percentage / 100);
  return calculateAmount({ amount: amount.toString(), decimals });
};
const minimumRecieveAmount = ({ amount }, percentage) => parseFloat(assertAmount(amount)) * (100 - percentage) / 100;
const calculateUsdAmount = ({
  amount,
  price
}) => parseFloat(assertAmount(amount)) * price;
const calculateDeadline = (minutes) => Date.now() + minutes * 60 * 1e3;
const calculateBalance = ({ balance, decimals }) => transformAmount(decimals, balance.toString());
const calculatePoolSupply = (token1, token2, pool) => {
  const amount1 = parseFloat(assertAmount(token1.amount));
  const amount2 = parseFloat(assertAmount(token2.amount));
  if (!pool) {
    return Math.sqrt(amount1 * amount2) - 1e-15;
  }
  const totalSupply = convert2Normal(18, pool.totalSupply);
  const reserve1 = convert2Normal(token1.decimals, pool.reserve1);
  const reserve2 = convert2Normal(token2.decimals, pool.reserve2);
  return Math.min(
    amount1 * totalSupply / reserve1,
    amount2 * totalSupply / reserve2
  );
};
const removeSupply = (percentage, supply, decimals) => supply && decimals ? convert2Normal(decimals, supply) * percentage / 100 : 0;
const removePoolTokenShare = (percentage, token) => token ? token.balance.mul(percentage).div(100).toString() : "0";
const showRemovePoolTokenShare = (percentage, token) => token ? convert2Normal(18, removePoolTokenShare(percentage, token)).toFixed(8) : "0";
const removeUserPoolSupply = (percentage, pool) => removeSupply(percentage, pool?.userPoolBalance, 18);
const convertAmount = (amount, fromPrice, toPrice) => parseFloat(assertAmount(amount)) / fromPrice * toPrice;
const calculatePoolRatio = (pool, first = true) => {
  if (!pool) {
    return 0;
  }
  const a1 = import_ethers.BigNumber.from(pool.reserve1);
  const a2 = import_ethers.BigNumber.from(pool.reserve2);
  const r1 = a1.mul(1e6).div(a2).toNumber() / 1e6;
  const r2 = a2.mul(1e6).div(a1).toNumber() / 1e6;
  return first ? r1 : r2;
};
const calculatePoolShare = (pool) => {
  if (!pool) {
    return 0;
  }
  const totalSupply = convert2Normal(18, pool.totalSupply);
  const userSupply = convert2Normal(18, pool.userPoolBalance);
  return userSupply / totalSupply * 100;
};
const showBalance = ({ decimals, balance, name, symbol }, decimalPoints = 4) => {
  if (!balance) {
    return "";
  }
  const balanceStr = balance.toString();
  if (balanceStr === "0") {
    return `${balanceStr} ${symbol || name}`;
  }
  const headLength = Math.max(balanceStr.length - decimals, 0);
  const tailLength = Math.max(headLength + decimalPoints, 0);
  const head = balanceStr.length < decimals ? "0" : balanceStr.slice(0, headLength);
  let tail = balanceStr.slice(headLength, tailLength);
  if (tail.search(/[^0]+/gm) === -1) {
    tail = "";
  }
  return tail.length ? `${head}.${tail} ${symbol || name}` : `${head} ${symbol || name}`;
};
const toBalance = ({ balance, decimals }) => {
  const num = balance.toString();
  const diff = num.length - decimals;
  const fullNum = diff <= 0 ? "0" : num.slice(0, diff);
  return parseFloat(`${fullNum}.${num.slice(diff, num.length)}`);
};
const toUnits = ({ balance, decimals }) => import_ethers.utils.formatUnits(balance.toString(), decimals);
const exponentNrSplit = (numberVal) => {
  const split = numberVal.split(/[eE]/);
  return {
    isExponent: split.length === 2,
    split
  };
};
const noExponents = (valueNr) => {
  let [leader, mag, multiplier, num, sign, str, z, expVal, res] = Array(0);
  const { split: data, isExponent } = exponentNrSplit(valueNr);
  if (!isExponent) {
    return valueNr;
  }
  z = "";
  sign = valueNr.slice(0, 1) === "-" ? "-" : "";
  str = data[0].replace(".", "");
  expVal = data[1].startsWith("+") ? data[1].substring(1) : data[1];
  mag = Number(expVal) + 1;
  if (mag <= 0) {
    z = `${sign}0.`;
    while (!(mag >= 0)) {
      z += "0";
      mag += 1;
    }
    num = z + str.replace(/^-/, "");
    return num;
  }
  if (str.length <= mag) {
    mag -= str.length;
    while (!(mag <= 0)) {
      z += 0;
      mag -= 1;
    }
    num = str + z;
    return num;
  }
  leader = import_ethers.utils.parseEther(data[0]);
  multiplier = import_ethers.BigNumber.from("10").pow(import_ethers.BigNumber.from(expVal));
  res = leader.mul(multiplier).toString();
  return import_ethers.utils.formatEther(res).toString();
};
const toDecimalPlaces = (value, maxDecimalPlaces) => {
  const decimalDelim = value.indexOf(".");
  const exponentSplit = exponentNrSplit(value);
  if (!value || decimalDelim < 1 && !exponentSplit.isExponent || value.length - decimalDelim < maxDecimalPlaces) {
    return value;
  }
  const noExpValue = noExponents(value);
  return noExpValue.substring(0, decimalDelim + 1 + maxDecimalPlaces);
};
const poolRatio = ({ token1, token2 }) => {
  if (!token1.decimals || !token2.decimals) {
    console.warn("getInputAmount pool param does not have Token types");
    return 0;
  }
  return toBalance(token2) / toBalance(token1);
};
const ensureAmount = (token) => (0, import_utils2.ensure)(
  import_ethers.BigNumber.from(calculateAmount(token)).lte(token.balance),
  `Insufficient ${token.name} balance`
);
const getOutputAmount = (token, pool) => {
  if (!pool.token1.decimals || !pool.token2.decimals) {
    console.warn("getOutputAmount pool param does not have Token types");
    return 0;
  }
  const inputAmount = parseFloat(assertAmount(token.amount)) * 997;
  const inputReserve = convert2Normal(
    pool.token1.decimals,
    pool.reserve1
  );
  const outputReserve = convert2Normal(
    pool.token2.decimals,
    pool.reserve2
  );
  const numerator = inputAmount * outputReserve;
  const denominator = inputReserve * 1e3 + inputAmount;
  return numerator / denominator;
};
const getInputAmount = (token, pool) => {
  if (!pool.token1.decimals || !pool.token2.decimals) {
    console.warn("getInputAmount pool param does not have Token types");
    return 0;
  }
  const outputAmount = parseFloat(assertAmount(token.amount));
  const inputReserve = convert2Normal(
    pool.token1.decimals,
    pool.reserve1
  );
  const outputReserve = convert2Normal(
    pool.token2.decimals,
    pool.reserve2
  );
  const numerator = inputReserve * outputAmount * 1e3;
  const denominator = (outputReserve - outputAmount) * 997;
  return numerator / denominator;
};
const calculateImpactPercentage = (sell, buy) => {
  const buyUsd = calculateUsdAmount(buy);
  const sellUsd = calculateUsdAmount(sell);
  if (sellUsd === 0) {
    return 0;
  }
  return (buyUsd - sellUsd) / sellUsd;
};
const getHashSumLastNr = (address) => {
  const summ = address.split("").reduce((sum, ch) => {
    const nr = parseInt(ch, 10);
    if (!Number.isNaN(nr)) {
      return sum + nr;
    }
    return sum;
  }, 0).toString(10);
  return parseInt(summ.substring(summ.length - 1), 10);
};
const toHumanAmount = (amount) => {
  const head = amount.slice(0, amount.indexOf("."));
  const amo = amount.replace(".", "");
  if (head.length > 9) {
    return `${amo.slice(0, head.length - 9)}.${amo.slice(
      head.length - 9,
      head.length - 9 + 2
    )} B`;
  }
  if (head.length > 6) {
    return `${amo.slice(0, head.length - 6)}.${amo.slice(
      head.length - 6,
      head.length - 6 + 2
    )} M`;
  }
  if (head.length > 3) {
    return `${amo.slice(0, head.length - 3)}.${amo.slice(
      head.length - 3,
      head.length - 3 + 2
    )} k`;
  }
  return amount.slice(0, head.length + 4);
};
const formatAmount = (amount, decimals) => {
  let amo = amount.toLocaleString("fullwide", { useGrouping: false });
  if (amo.indexOf(".") !== -1) {
    amo = amo.substring(0, amo.indexOf("."));
  }
  if (amo.indexOf(",") !== -1) {
    amo = amo.substring(0, amo.indexOf(","));
  }
  return toHumanAmount(import_ethers.utils.formatUnits(amo, decimals));
};
const mean = (arr) => arr.reduce((acc, v) => acc + v) / arr.length;
const variance = (arr) => {
  const avg = mean(arr);
  const squareDiffs = arr.map((v) => {
    const diff = avg - v;
    return diff * diff;
  });
  return mean(squareDiffs);
};
const std = (arr) => Math.sqrt(variance(arr));
const checkMinExistentialReefAmount = (token, reefBalance) => {
  const nativeReefTransfer = (0, import_tokenUtil.isNativeTransfer)(token);
  const FIXED_TX_FEE = nativeReefTransfer ? 2 : 3;
  const minAmountBesidesTx = nativeReefTransfer ? import_utils2.MIN_NATIVE_TX_BALANCE : import_utils2.MIN_EVM_TX_BALANCE;
  const reservedTxMin = calculateAmount({
    decimals: import_tokenModel.REEF_TOKEN.decimals,
    amount: (minAmountBesidesTx + FIXED_TX_FEE).toString()
  });
  const transferAmt = import_ethers.BigNumber.from((0, import_utils.parseEther)(assertAmount(token.amount)));
  const requiredReefMin = nativeReefTransfer ? import_ethers.BigNumber.from(reservedTxMin).add(transferAmt) : import_ethers.BigNumber.from(reservedTxMin);
  const maxTransfer = reefBalance.sub(import_ethers.BigNumber.from(reservedTxMin));
  const valid = reefBalance.gte(requiredReefMin);
  let message = "";
  if (!valid) {
    message = `${(0, import_utils2.toReefBalanceDisplay)(
      import_ethers.BigNumber.from(reservedTxMin)
    )} balance needed to call EVM transaction. Token transfer fee ~2.5 REEF.`;
    if (nativeReefTransfer) {
      const maxTransfer2 = reefBalance.sub(import_ethers.BigNumber.from(reservedTxMin));
      message = `Maximum transfer amount is ~${(0, import_utils2.toReefBalanceDisplay)(
        maxTransfer2
      )} to allow for fees.`;
    }
  }
  return { valid, message, maxTransfer };
};
const ensureTokenAmount = (token) => (0, import_utils2.ensure)(
  import_ethers.BigNumber.from(calculateAmount(token)).lte(token.balance),
  `Insufficient ${token.name} balance`
);
const ensureExistentialReefAmount = (token, reefBalance) => {
  (0, import_utils2.ensure)(
    checkMinExistentialReefAmount(token, reefBalance).valid,
    "Insufficient REEF balance."
  );
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  assertAmount,
  calculateAmount,
  calculateAmountWithPercentage,
  calculateBalance,
  calculateDeadline,
  calculateImpactPercentage,
  calculatePoolRatio,
  calculatePoolShare,
  calculatePoolSupply,
  calculateUsdAmount,
  checkMinExistentialReefAmount,
  convert2Normal,
  convertAmount,
  ensureAmount,
  ensureExistentialReefAmount,
  ensureTokenAmount,
  exponentNrSplit,
  formatAmount,
  getHashSumLastNr,
  getInputAmount,
  getOutputAmount,
  mean,
  minimumRecieveAmount,
  noExponents,
  poolRatio,
  removePoolTokenShare,
  removeSupply,
  removeUserPoolSupply,
  showBalance,
  showRemovePoolTokenShare,
  std,
  toBalance,
  toDecimalPlaces,
  toHumanAmount,
  toUnits,
  transformAmount,
  variance
});
