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
var evmEvents_rx_exports = {};
__export(evmEvents_rx_exports, {
  getEvmEvents$: () => getEvmEvents$
});
module.exports = __toCommonJS(evmEvents_rx_exports);
var import_ethers = require("ethers");
var import_rxjs = require("rxjs");
var import_latestBlock = require("../reefState/latestBlock");
var import_httpClient = require("../graphql/httpClient");
var import_operators = require("rxjs/operators");
var import_gqlUtil = require("../graphql/gqlUtil");
const getGqlContractEventsQuery = (contractAddress, methodSignature, fromBlockId, toBlockId) => {
  const EVM_EVENT_QUERY = `
    query evmEvent(
      $address: String_comparison_exp!
      $blockId: bigint_comparison_exp!
      $topic0: String_comparison_exp
    ) {
      evm_event(
        order_by: [
          { block_id: desc }
          { extrinsic_index: desc }
          { event_index: desc }
        ]
        where: {
          _and: [
            { contract_address: $address }
            { topic_0: $topic0 }
            { method: { _eq: "Log" } }
            { block_id: $blockId }
          ]
        }
      ) {
        contract_address
        data_parsed
        data_raw
        topic_0
        topic_1
        topic_2
        topic_3
        block_id
        extrinsic_index
        event_index
      }
    }
  `;
  return {
    query: EVM_EVENT_QUERY,
    variables: {
      address: { _eq: contractAddress },
      topic0: methodSignature ? { _eq: import_ethers.utils.keccak256(import_ethers.utils.toUtf8Bytes(methodSignature)) } : {},
      blockId: toBlockId ? { _gte: fromBlockId, _lte: toBlockId } : { _eq: fromBlockId }
    }
  };
};
function getEvmEvents$(contractAddress, methodSignature, fromBlockId, toBlockId) {
  if (!contractAddress) {
    console.warn("getEvmEvents$ expects contractAddress");
    return (0, import_rxjs.of)(null);
  }
  if (!fromBlockId) {
    return import_httpClient.httpClientInstance$.pipe(
      (0, import_rxjs.switchMap)(
        (httpClient) => (0, import_latestBlock.getLatestBlockContractEvents$)([contractAddress]).pipe(
          (0, import_rxjs.map)((latestBlock) => ({
            fromBlockId: latestBlock.blockHeight,
            toBlockId: void 0
          })),
          (0, import_operators.filter)((lb) => toBlockId ? lb.fromBlockId <= toBlockId : true),
          (0, import_rxjs.switchMap)(
            (res) => (0, import_gqlUtil.queryGql$)(
              httpClient,
              getGqlContractEventsQuery(
                contractAddress,
                methodSignature,
                res.fromBlockId,
                res.toBlockId
              )
            ).pipe(
              (0, import_rxjs.map)((events) => ({
                fromBlockId: res.fromBlockId,
                toBlockId: res.toBlockId || res.fromBlockId,
                evmEvents: events.data.evm_event
              }))
            )
          )
        )
      ),
      (0, import_rxjs.shareReplay)(1)
    );
  }
  return import_httpClient.httpClientInstance$.pipe(
    (0, import_rxjs.switchMap)(
      (httpClient) => (0, import_gqlUtil.queryGql$)(
        httpClient,
        getGqlContractEventsQuery(
          contractAddress,
          methodSignature,
          fromBlockId,
          toBlockId
        )
      )
    ),
    (0, import_rxjs.map)((events) => ({
      fromBlockId,
      toBlockId: toBlockId || fromBlockId,
      evmEvents: events.data.evm_event
    })),
    (0, import_rxjs.shareReplay)(1)
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getEvmEvents$
});
