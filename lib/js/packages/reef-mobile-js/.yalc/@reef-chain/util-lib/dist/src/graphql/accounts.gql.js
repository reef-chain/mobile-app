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
var accounts_gql_exports = {};
__export(accounts_gql_exports, {
  EVM_ADDRESS_UPDATE_QUERY: () => EVM_ADDRESS_UPDATE_QUERY,
  getEvmAddressQuery: () => getEvmAddressQuery
});
module.exports = __toCommonJS(accounts_gql_exports);
const EVM_ADDRESS_UPDATE_QUERY = `
  query evmAddresses($accountIds: [String!]!) {
    accounts(where: { id_in: $accountIds }, orderBy: timestamp_DESC) {
      id
      evmAddress
    }
  }
`;
const getEvmAddressQuery = (accountIds) => {
  return {
    query: EVM_ADDRESS_UPDATE_QUERY,
    variables: { accountIds }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  EVM_ADDRESS_UPDATE_QUERY,
  getEvmAddressQuery
});
