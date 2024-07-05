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
var utils_exports = {};
__export(utils_exports, {
  MIN_EVM_TX_BALANCE: () => MIN_EVM_TX_BALANCE,
  MIN_NATIVE_TX_BALANCE: () => MIN_NATIVE_TX_BALANCE,
  REEF_ADDRESS_SPECIFIC_STRING: () => REEF_ADDRESS_SPECIFIC_STRING,
  addReefSpecificStringFromAddress: () => addReefSpecificStringFromAddress,
  dropDuplicatesMultiKey: () => dropDuplicatesMultiKey,
  ensure: () => ensure,
  ensureVoidRun: () => ensureVoidRun,
  errorStatus: () => errorStatus,
  formatAgoDate: () => formatAgoDate,
  removeReefSpecificStringFromAddress: () => removeReefSpecificStringFromAddress,
  removeUndefinedItem: () => removeUndefinedItem,
  shortAddress: () => shortAddress,
  toAddressShortDisplay: () => toAddressShortDisplay,
  toReefBalanceDisplay: () => toReefBalanceDisplay,
  trim: () => trim,
  uniqueCombinations: () => uniqueCombinations
});
module.exports = __toCommonJS(utils_exports);
var import_ethers = require("ethers");
const REEF_ADDRESS_SPECIFIC_STRING = "(ONLY for Reef chain!)";
const MIN_NATIVE_TX_BALANCE = 1;
const MIN_EVM_TX_BALANCE = 65;
const trim = (value, size = 19) => value.length < size ? value : `${value.slice(0, size - 5)}...${value.slice(value.length - 5)}`;
const toAddressShortDisplay = (address) => trim(address, 7);
const shortAddress = (address) => address.length > 10 ? `${address.slice(0, 5)}...${address.slice(
  address.length - 5,
  address.length
)}` : address;
const ensure = (condition, message) => {
  if (!condition) {
    throw new Error(message);
  }
};
const toReefBalanceDisplay = (value) => {
  if (value && value.gt(0)) {
    const stringValue = import_ethers.ethers.utils.formatEther(value);
    const delimiterIndex = stringValue.indexOf(".");
    return `${stringValue.substring(0, delimiterIndex)} REEF`;
  }
  return "- REEF";
};
const uniqueCombinations = (array) => {
  const result = [];
  for (let i = 0; i < array.length; i += 1) {
    for (let j = i + 1; j < array.length; j += 1) {
      result.push([array[i], array[j]]);
    }
  }
  return result;
};
const errorStatus = (text) => ({
  isValid: false,
  text
});
const ensureVoidRun = (canRun) => (fun, obj) => {
  if (canRun) {
    fun(obj);
  }
};
const removeUndefinedItem = (item) => item !== void 0;
const formatAgoDate = (timestamp) => {
  const now = new Date(Date.now());
  const date = new Date(timestamp);
  const difference = now.getTime() - date.getTime();
  if (difference < 1e3 * 60) {
    return `${Math.round(difference / 1e3)}sec ago`;
  }
  if (difference < 1e3 * 60 * 60) {
    return `${Math.round(difference / 6e4)}min ago`;
  }
  if (difference < 1e3 * 60 * 60 * 24) {
    return `${Math.round(difference / 36e5)}h ago`;
  }
  return date.toDateString();
};
const dropDuplicatesMultiKey = (objects, keys) => {
  const existingKeys = /* @__PURE__ */ new Set();
  const filtered = [];
  for (let index = objects.length - 1; index >= 0; index -= 1) {
    const obj = objects[index];
    const ids = keys.map((key) => obj[key]).join(", ");
    if (!existingKeys.has(ids)) {
      filtered.push(obj);
      existingKeys.add(ids);
    }
  }
  return filtered;
};
const removeReefSpecificStringFromAddress = (address) => address.replace(REEF_ADDRESS_SPECIFIC_STRING, "").trim();
const addReefSpecificStringFromAddress = (address) => `${address}${REEF_ADDRESS_SPECIFIC_STRING}`;
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  MIN_EVM_TX_BALANCE,
  MIN_NATIVE_TX_BALANCE,
  REEF_ADDRESS_SPECIFIC_STRING,
  addReefSpecificStringFromAddress,
  dropDuplicatesMultiKey,
  ensure,
  ensureVoidRun,
  errorStatus,
  formatAgoDate,
  removeReefSpecificStringFromAddress,
  removeUndefinedItem,
  shortAddress,
  toAddressShortDisplay,
  toReefBalanceDisplay,
  trim,
  uniqueCombinations
});
