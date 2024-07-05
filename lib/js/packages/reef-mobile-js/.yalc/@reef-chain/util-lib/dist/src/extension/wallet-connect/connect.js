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
var connect_exports = {};
__export(connect_exports, {
  WC_PROJECT_ID: () => WC_PROJECT_ID,
  initWcClient: () => initWcClient
});
module.exports = __toCommonJS(connect_exports);
var import_sign_client = __toESM(require("@walletconnect/sign-client"));
var import_utils = require("@walletconnect/utils");
const WC_PROJECT_ID = "b20768c469f63321e52923a168155240";
const WC_RELAY_URL = "wss://relay.walletconnect.com";
const WC_LOGGER = "error";
const initWcClient = async (metadata) => {
  return await import_sign_client.default.init({
    logger: WC_LOGGER,
    relayUrl: WC_RELAY_URL,
    projectId: WC_PROJECT_ID,
    metadata: metadata || (0, import_utils.getAppMetadata)()
  });
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  WC_PROJECT_ID,
  initWcClient
});
