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
var availablePools_gql_exports = {};
__export(availablePools_gql_exports, {
  getAvailablePoolsQuery: () => getAvailablePoolsQuery
});
module.exports = __toCommonJS(availablePools_gql_exports);
const AVAILABLE_POOLS_QUERY = `
  query pools_query($hasTokenAddress: String!) {
    verified_pool(
      where: {
        _or: [
          { token_1: { _eq: $hasTokenAddress } }
          { token_2: { _eq: $hasTokenAddress } }
        ]
        _and: [
          # volume not null
          { volume: {} }
        ]
      }
      order_by: {
        #volume_aggregate: {sum: {amount_1: desc}}
        supply_aggregate: { sum: { supply: desc } }
      }
    ) {
      address
      pool_decimal
      token_1
      token_2
      name_1
      name_2
      symbol_1
      symbol_2
      decimal_1
      decimal_2
      supply(limit: 1, order_by: { timeframe: desc }) {
        total_supply
      }
      volume_aggregate {
        aggregate {
          sum {
            amount_1
            amount_2
          }
          max {
            timeframe
          }
        }
      }
    }
  }
`;
const getAvailablePoolsQuery = (withTokenAddress) => {
  return {
    query: AVAILABLE_POOLS_QUERY,
    variables: { hasTokenAddress: withTokenAddress }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getAvailablePoolsQuery
});
