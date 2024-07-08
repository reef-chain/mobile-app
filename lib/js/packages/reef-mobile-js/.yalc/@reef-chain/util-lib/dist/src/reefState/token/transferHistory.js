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
var transferHistory_exports = {};
__export(transferHistory_exports, {
  loadTransferHistory: () => loadTransferHistory
});
module.exports = __toCommonJS(transferHistory_exports);
var import_tokenModel = require("../../token/tokenModel");
var import_rxjs = require("rxjs");
var import_nftUtil = require("../../token/nftUtil");
var import_ethers = require("ethers");
var import_transferHistory = require("../../graphql/transferHistory.gql");
var import_accountSignerUtils = require("../../account/accountSignerUtils");
var import_tokenUtil = require("./tokenUtil");
var import_nftUtils = require("./nftUtils");
var import_getIconUrl = require("../../token/getIconUrl");
var import_transactionUtil = require("../../token/transactionUtil");
var import_gqlUtil = require("../../graphql/gqlUtil");
const resolveTransferHistoryNfts = (tokens, signer) => {
  const nftOrNull = tokens.map(
    (tr) => "contractType" in tr && (tr.contractType === import_tokenModel.ContractType.ERC1155 || tr.contractType === import_tokenModel.ContractType.ERC721) ? tr : null
  );
  if (!nftOrNull.filter((v) => !!v).length) {
    return (0, import_rxjs.of)(tokens);
  }
  return (0, import_rxjs.of)(nftOrNull).pipe(
    (0, import_rxjs.switchMap)(
      (nfts) => (0, import_nftUtil.resolveNftImageLinks)(nfts, signer, import_nftUtils._NFT_IPFS_RESOLVER_FN)
    ),
    (0, import_rxjs.map)((nftOrNullResolved) => {
      const resolvedNftTransfers = [];
      nftOrNullResolved.forEach((nftOrN, i) => {
        resolvedNftTransfers.push(nftOrN || tokens[i]);
      });
      return resolvedNftTransfers;
    })
  );
};
const toTransferToken = (transfer) => transfer.token.type === import_tokenModel.ContractType.ERC20 ? {
  address: transfer.token.id,
  balance: import_ethers.BigNumber.from((0, import_tokenUtil.toPlainString)(transfer.amount)),
  name: transfer.token.contractData?.name || transfer.token.name,
  symbol: transfer.token.contractData?.symbol,
  decimals: transfer.token.contractData?.decimals || 18,
  iconUrl: transfer.token.contractData?.iconUrl || (0, import_getIconUrl.getIconUrl)(transfer.token.id)
} : {
  address: transfer.token.id,
  balance: import_ethers.BigNumber.from((0, import_tokenUtil.toPlainString)(transfer.amount)),
  name: transfer.token.contractData?.name || transfer.token.name,
  symbol: "",
  decimals: 0,
  iconUrl: "",
  nftId: transfer.nftId,
  contractType: transfer.token.type
};
const toTokenTransfers = (resTransferData, signer, network) => resTransferData.map(
  (transferData) => ({
    from: transferData.from?.id,
    to: transferData.to.id,
    inbound: !!signer.evmAddress && transferData.to.evmAddress === signer.evmAddress || transferData.to.id === signer.address,
    timestamp: transferData.timestamp,
    token: toTransferToken(transferData),
    url: (0, import_transactionUtil.getTransferUrl)(
      transferData.blockHeight,
      transferData.extrinsicIndex,
      transferData.eventIndex,
      network
    ),
    extrinsic: {
      blockId: transferData.blockHash,
      blockHeight: transferData.blockHeight,
      id: transferData.blockHeight + "-" + transferData.extrinsicIndex,
      index: transferData.extrinsicIndex,
      hash: transferData.blockHash,
      eventIndex: transferData.eventIndex
    },
    type: transferData.type,
    reefswapAction: transferData.reefswapAction,
    success: transferData.success
  })
);
const loadTransferHistory = ([
  httpClient,
  account,
  network,
  provider,
  forceReload,
  anyBalanceUpdate
]) => !account ? (0, import_rxjs.of)([]) : (0, import_gqlUtil.queryGql$)(httpClient, (0, import_transferHistory.getSignerHistoryQuery)(account.data.address)).pipe(
  (0, import_rxjs.map)((res) => {
    if (res?.data?.transfers) {
      return res.data.transfers;
    }
    throw new Error("Could not load data.");
  }),
  (0, import_rxjs.map)((resData) => {
    return toTokenTransfers(resData, account.data, network);
  }),
  (0, import_rxjs.switchMap)((transfers) => {
    const tokens = transfers.map((tr) => tr.token);
    const sig$ = (0, import_rxjs.from)((0, import_accountSignerUtils.getReefAccountSigner)(account.data, provider));
    return (0, import_rxjs.from)(sig$).pipe(
      (0, import_rxjs.switchMap)(
        (sig) => sig ? resolveTransferHistoryNfts(tokens, sig) : []
      ),
      (0, import_rxjs.map)(
        (resolvedTokens) => resolvedTokens.map((resToken, i) => ({
          ...transfers[i],
          token: resToken
        }))
      )
    );
  })
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  loadTransferHistory
});
