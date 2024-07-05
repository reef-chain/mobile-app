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
var nftUtils_exports = {};
__export(nftUtils_exports, {
  _NFT_IPFS_RESOLVER_FN: () => _NFT_IPFS_RESOLVER_FN,
  loadSignerNfts: () => loadSignerNfts,
  setNftIpfsResolverFn: () => setNftIpfsResolverFn
});
module.exports = __toCommonJS(nftUtils_exports);
var import_rxjs = require("rxjs");
var import_ethers = require("ethers");
var import_nftUtil = require("../../token/nftUtil");
var import_statusDataObject = require("../model/statusDataObject");
var import_signerNfts = require("../../graphql/signerNfts.gql");
var import_accountSignerUtils = require("../../account/accountSignerUtils");
var import_providerState = require("../providerState");
var import_gqlUtil = require("../../graphql/gqlUtil");
let _NFT_IPFS_RESOLVER_FN;
const setNftIpfsResolverFn = (val) => {
  _NFT_IPFS_RESOLVER_FN = val;
};
const parseTokenHolderArray = (resArr) => resArr.map(
  ({ balance, nftId, token: { id: address, type: contractType } }) => {
    return {
      contractType,
      balance: import_ethers.BigNumber.from(balance),
      nftId,
      symbol: "",
      decimals: 0,
      address,
      iconUrl: "",
      name: ""
    };
  }
);
const loadSignerNfts = ([
  httpClient,
  signer,
  forceReload,
  nftBalanceUpdated
]) => !signer || !httpClient ? (0, import_rxjs.of)(
  (0, import_statusDataObject.toFeedbackDM)(
    [],
    import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
    "Signer not set"
  )
) : (
  /*zenToRx(
    httpClient.subscribe({
      query: SIGNER_NFTS_GQL,
      variables: {
        accountId: (signer.data as ReefAccount).address,
      },
      fetchPolicy: "network-only",
    })
  )*/
  (0, import_gqlUtil.queryGql$)(httpClient, (0, import_signerNfts.getSignerNftsQuery)(signer.data.address)).pipe(
    (0, import_rxjs.map)((res) => {
      if (res?.data?.tokenHolders) {
        return res.data.tokenHolders;
      }
      if ((0, import_statusDataObject.isFeedbackDM)(res)) {
        return res;
      }
      throw new Error("Could not load data.");
    }),
    (0, import_rxjs.map)((res) => parseTokenHolderArray(res)),
    // TODO handle SDO- map((res: VerifiedNft[]|FeedbackDataModel<NFT[]>) => isFeedbackDM(res)?res:parseTokenHolderArray(res)),
    (0, import_rxjs.switchMap)(
      (nftArr) => (0, import_rxjs.combineLatest)([(0, import_rxjs.of)(nftArr), import_providerState.instantProvider$]).pipe(
        (0, import_rxjs.switchMap)(
          (nftsAndProvider) => {
            const [nfts, provider] = nftsAndProvider;
            if (!provider) {
              return (0, import_rxjs.of)(
                nfts.map(
                  (nft) => (0, import_statusDataObject.toFeedbackDM)(
                    nft,
                    import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
                    "Provider not connected."
                  )
                )
              );
            }
            const sig$ = (0, import_rxjs.from)((0, import_accountSignerUtils.getReefAccountSigner)(signer.data, provider));
            return sig$.pipe(
              (0, import_rxjs.switchMap)((sig) => {
                if (!sig) {
                  return (0, import_rxjs.of)(
                    nfts.map(
                      (nft) => (0, import_statusDataObject.toFeedbackDM)(
                        nft,
                        import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
                        "Could not create Signer."
                      )
                    )
                  );
                }
                return (0, import_nftUtil.resolveNftImageLinks$)(
                  nfts,
                  sig,
                  _NFT_IPFS_RESOLVER_FN
                );
              })
            );
          }
        ),
        (0, import_rxjs.map)(
          (feedbackNfts) => {
            const codes = (0, import_statusDataObject.collectFeedbackDMStatus)(feedbackNfts);
            let message = codes.some(
              (c) => c === import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING
            ) ? "Resolving nft urls." : "";
            if (!feedbackNfts.length) {
              message = "No nfts found";
              codes.push(import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA);
            }
            return (0, import_statusDataObject.toFeedbackDM)(feedbackNfts, codes, message);
          }
        )
      )
    ),
    (0, import_rxjs.catchError)(
      (err) => (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message))
    )
  )
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  _NFT_IPFS_RESOLVER_FN,
  loadSignerNfts,
  setNftIpfsResolverFn
});
