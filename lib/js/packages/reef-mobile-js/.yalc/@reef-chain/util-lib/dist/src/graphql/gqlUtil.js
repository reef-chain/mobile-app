var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from2, except, desc) => {
  if (from2 && typeof from2 === "object" || typeof from2 === "function") {
    for (let key of __getOwnPropNames(from2))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from2[key], enumerable: !(desc = __getOwnPropDesc(from2, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var gqlUtil_exports = {};
__export(gqlUtil_exports, {
  getGQLUrls: () => getGQLUrls,
  graphQlUrls$: () => graphQlUrls$,
  graphqlRequest: () => graphqlRequest,
  queryGql$: () => queryGql$
});
module.exports = __toCommonJS(gqlUtil_exports);
var import_rxjs = require("rxjs");
var import_networkState = require("../reefState/networkState");
const getGQLUrls = (network) => {
  if (!network.graphqlExplorerUrl) {
    return void 0;
  }
  const ws = network.graphqlExplorerUrl.startsWith("http") ? network.graphqlExplorerUrl.replace("http", "ws") : network.graphqlExplorerUrl;
  const http = network.graphqlExplorerUrl.startsWith("ws") ? network.graphqlExplorerUrl.replace("ws", "http") : network.graphqlExplorerUrl;
  return { ws, http };
};
const graphqlRequest = (httpClient, queryObj) => {
  const graphql = JSON.stringify(queryObj);
  return httpClient.post("", graphql, {
    headers: { "Content-Type": "application/json" }
  });
};
const graphQlUrls$ = import_networkState.selectedNetwork$.pipe(
  (0, import_rxjs.map)(getGQLUrls),
  (0, import_rxjs.shareReplay)(1)
);
const queryGql$ = (client, queryObj) => (0, import_rxjs.from)(graphqlRequest(client, queryObj).then((res) => res.data));
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getGQLUrls,
  graphQlUrls$,
  graphqlRequest,
  queryGql$
});
