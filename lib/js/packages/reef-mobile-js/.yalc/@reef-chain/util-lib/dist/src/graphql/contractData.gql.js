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
var contractData_gql_exports = {};
__export(contractData_gql_exports, {
  getContractAbiQuery: () => getContractAbiQuery,
  getContractDataQuery: () => getContractDataQuery
});
module.exports = __toCommonJS(contractData_gql_exports);
const CONTRACT_DATA_QUERY = `
  query contract_data_query($addresses: [String!]!) {
    verifiedContracts(where: { id_in: $addresses }, limit: 300) {
      id
      contractData
    }
  }
`;
const getContractDataQuery = (addresses) => {
  return {
    query: CONTRACT_DATA_QUERY,
    variables: { addresses }
  };
};
const CONTRACT_ABI_QUERY = `
  query contract_data_query($address: String!) {
    verifiedContracts(where: { id_containsInsensitive: $address }, limit: 1) {
      id
      compiledData
    }
  }
`;
const getContractAbiQuery = (address) => {
  return {
    query: CONTRACT_ABI_QUERY,
    variables: { address }
  };
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getContractAbiQuery,
  getContractDataQuery
});
