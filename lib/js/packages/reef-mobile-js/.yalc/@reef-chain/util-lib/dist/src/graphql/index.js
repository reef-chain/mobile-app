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
var graphql_exports = {};
__export(graphql_exports, {
  EVM_ADDRESS_UPDATE_QUERY: () => import_accounts.EVM_ADDRESS_UPDATE_QUERY,
  TRANSFER_HISTORY_QUERY: () => import_transferHistory.TRANSFER_HISTORY_QUERY,
  getContractDataQuery: () => import_contractData.getContractDataQuery,
  httpClientInstance$: () => import_httpClient.httpClientInstance$,
  queryGql$: () => import_gqlUtil.queryGql$
});
module.exports = __toCommonJS(graphql_exports);
var import_transferHistory = require("./transferHistory.gql");
var import_accounts = require("./accounts.gql");
var import_contractData = require("./contractData.gql");
var import_gqlUtil = require("./gqlUtil");
var import_httpClient = require("./httpClient");
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  EVM_ADDRESS_UPDATE_QUERY,
  TRANSFER_HISTORY_QUERY,
  getContractDataQuery,
  httpClientInstance$,
  queryGql$
});
