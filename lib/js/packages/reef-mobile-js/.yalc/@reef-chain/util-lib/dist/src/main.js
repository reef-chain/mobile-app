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
var __reExport = (target, mod, secondTarget) => (__copyProps(target, mod, "default"), secondTarget && __copyProps(secondTarget, mod, "default"));
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var main_exports = {};
__export(main_exports, {
  addressUtils: () => addressUtils,
  balanceUtils: () => balanceUtils,
  evm: () => evm,
  extension: () => extension,
  graphql: () => graphql,
  logoSvgUrl: () => logoSvgUrl,
  network: () => network,
  reefState: () => reefState,
  signatureUtils: () => signatureUtils,
  tokenUtil: () => tokenUtil,
  transactionUtils: () => transactionUtils
});
module.exports = __toCommonJS(main_exports);
var reefState = __toESM(require("./reefState"));
var network = __toESM(require("./network"));
var graphql = __toESM(require("./graphql"));
var tokenUtil = __toESM(require("./token"));
__reExport(main_exports, require("./account"), module.exports);
var evm = __toESM(require("./evm"));
var addressUtils = __toESM(require("./utils/addressUtils"));
var balanceUtils = __toESM(require("./utils/balanceUtils"));
var transactionUtils = __toESM(require("./transaction"));
var signatureUtils = __toESM(require("./signature/tx-signature-util"));
var extension = __toESM(require("./extension"));
var logoSvgUrl = __toESM(require("./utils/logoSvgUrl"));
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  addressUtils,
  balanceUtils,
  evm,
  extension,
  graphql,
  logoSvgUrl,
  network,
  reefState,
  signatureUtils,
  tokenUtil,
  transactionUtils,
  ...require("./account")
});
