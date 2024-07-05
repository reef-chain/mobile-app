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
var signerTokens_gql_exports = {};
__export(signerTokens_gql_exports, {
  ALL_TOKENS_QUERY: () => ALL_TOKENS_QUERY,
  SIGNER_TOKENS_QUERY: () => SIGNER_TOKENS_QUERY,
  getAllTokensQuery: () => getAllTokensQuery,
  getSignerTokensQuery: () => getSignerTokensQuery
});
module.exports = __toCommonJS(signerTokens_gql_exports);
const SIGNER_TOKENS_QUERY = `
  query tokens_query($accountId: String!) {
    tokenHolders(
      where: {
        AND: {
          nftId_isNull: true
          token: { id_isNull: false }
          signer: { id_eq: $accountId }
          balance_gt: "0"
        }
      }
      orderBy: balance_DESC
      limit: 320
    ) {
      token {
        id
      }
      balance
    }
  }
`;
const getSignerTokensQuery = (address) => {
  return {
    query: SIGNER_TOKENS_QUERY,
    variables: {
      accountId: address
    }
  };
};
const ALL_TOKENS_QUERY = `
  query tokens_query($offset: Int!) {
    tokenHolders(
      offset: $offset
      where: {
        AND: {
          nftId_isNull: true
          token: { id_isNull: false }
        }
      }
      orderBy: balance_DESC
      limit: 320
    ) {
      token {
        id
      }
      balance
    }
  }
`;
const getAllTokensQuery = (offset) => {
  return {
    query: ALL_TOKENS_QUERY,
    variables: { offset }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ALL_TOKENS_QUERY,
  SIGNER_TOKENS_QUERY,
  getAllTokensQuery,
  getSignerTokensQuery
});
