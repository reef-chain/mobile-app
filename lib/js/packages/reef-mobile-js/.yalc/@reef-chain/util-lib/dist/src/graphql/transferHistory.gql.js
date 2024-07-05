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
var transferHistory_gql_exports = {};
__export(transferHistory_gql_exports, {
  TRANSFER_HISTORY_QUERY: () => TRANSFER_HISTORY_QUERY,
  getSignerHistoryQuery: () => getSignerHistoryQuery
});
module.exports = __toCommonJS(transferHistory_gql_exports);
const TRANSFER_HISTORY_QUERY = `
  query transferHistory($accountId: String!) {
    transfers(
      where: {
        OR: [{ from: { id_eq: $accountId } }, { to: { id_eq: $accountId } }]
      }
      limit: 35
      orderBy: timestamp_DESC
    ) {
      timestamp
      amount
      fromEvmAddress
      id
      nftId
      success
      type
      toEvmAddress
      token {
        id
        name
        type
        contractData
      }
      signedData
      extrinsicHash
      extrinsicId
      eventIndex
      extrinsicIndex
      blockHeight
      blockHash
      finalized
      reefswapAction
      from {
        id
        evmAddress
      }
      to {
        id
        evmAddress
      }
      reefswapAction
    }
  }
`;
const getSignerHistoryQuery = (accountId) => {
  return {
    query: TRANSFER_HISTORY_QUERY,
    variables: { accountId }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TRANSFER_HISTORY_QUERY,
  getSignerHistoryQuery
});
