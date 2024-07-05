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
var poolUtils_exports = {};
__export(poolUtils_exports, {
  loadAvailablePools: () => loadAvailablePools,
  toAvailablePools: () => toAvailablePools
});
module.exports = __toCommonJS(poolUtils_exports);
var import_availablePools = require("../../graphql/availablePools.gql");
var import_tokenModel = require("../../token/tokenModel");
var import_gqlUtil = require("../../graphql/gqlUtil");
const loadAvailablePools = ([httpClient, provider]) => (0, import_gqlUtil.queryGql$)(httpClient, (0, import_availablePools.getAvailablePoolsQuery)(import_tokenModel.REEF_ADDRESS));
const toAvailablePools = ({ data: { verified_pool: pools } }) => pools.map((pool) => ({
  token1: pool.token_1,
  token2: pool.token_2,
  decimals: pool.pool_decimal,
  reserve1: null,
  reserve2: null,
  poolAddress: pool.address,
  userPoolBalance: null,
  totalVolumeToken1: pool.volume_aggregate.aggregate.sum.amount_1,
  totalVolumeToken2: pool.volume_aggregate.aggregate.sum.amount_2,
  lastTimeframe: pool.volume_aggregate.aggregate.max.timeframe,
  totalSupply: pool.supply[0]?.total_supply
}));
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  loadAvailablePools,
  toAvailablePools
});
