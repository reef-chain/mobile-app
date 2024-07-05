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
var selectedAccountTokenBalances_exports = {};
__export(selectedAccountTokenBalances_exports, {
  fetchTokensData: () => fetchTokensData,
  loadAccountTokens_sdo: () => loadAccountTokens_sdo,
  loadAllTokens_sdo: () => loadAllTokens_sdo,
  replaceReefBalanceFromAccount: () => replaceReefBalanceFromAccount,
  setReefBalanceFromAccount: () => setReefBalanceFromAccount
});
module.exports = __toCommonJS(selectedAccountTokenBalances_exports);
var import_tokenModel = require("../../token/tokenModel");
var import_ethers = require("ethers");
var import_rxjs = require("rxjs");
var import_statusDataObject = require("../model/statusDataObject");
var import_tokenUtil = require("./tokenUtil");
var import_getIconUrl = require("../../token/getIconUrl");
var import_signerTokens = require("../../graphql/signerTokens.gql");
var import_gqlUtil = require("../../graphql/gqlUtil");
var import_contractData = require("../../graphql/contractData.gql");
var import_tokenUtil2 = require("../../token/tokenUtil");
var import_nftUtil = require("../../token/nftUtil");
const fetchTokensData = (httpClient, missingCacheContractDataAddresses) => {
  if (!missingCacheContractDataAddresses.length) {
    return (0, import_rxjs.of)([]);
  }
  const distinctAddr = missingCacheContractDataAddresses.reduce(
    (distinctAddrList, curr) => {
      if (distinctAddrList.indexOf(curr) < 0) {
        distinctAddrList.push(curr);
      }
      return distinctAddrList;
    },
    []
  );
  return (0, import_gqlUtil.queryGql$)(httpClient, (0, import_contractData.getContractDataQuery)(distinctAddr)).pipe(
    (0, import_rxjs.take)(1),
    (0, import_rxjs.map)((verContracts) => {
      return verContracts.data.verifiedContracts.map(
        // eslint-disable-next-line camelcase
        (vContract) => {
          return {
            address: vContract.id,
            iconUrl: vContract.contractData?.iconUrl,
            decimals: vContract.contractData?.decimals || 18,
            name: vContract.contractData?.name,
            symbol: vContract.contractData?.symbol,
            balance: import_ethers.BigNumber.from(0)
          };
        }
      );
    }),
    (0, import_rxjs.shareReplay)(1),
    (0, import_rxjs.catchError)((err) => {
      console.log("fetchTokensData ERROR=", err);
      return (0, import_rxjs.of)([]);
    })
  );
};
function toTokensWithContractDataFn(tokenBalances) {
  return (cData) => {
    const tokens = tokenBalances.map(
      (tBalance) => {
        const cDataTkn = cData.find(
          (cd) => cd.address === tBalance.address
        );
        return cDataTkn ? (0, import_statusDataObject.toFeedbackDM)(
          {
            ...cDataTkn,
            balance: import_ethers.BigNumber.from((0, import_tokenUtil.toPlainString)(tBalance.balance))
          },
          import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA,
          "Contract data set"
        ) : (0, import_statusDataObject.toFeedbackDM)(
          { ...tBalance },
          import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
          "Loading contract data"
        );
      }
    );
    return { tokens, contractData: cData };
  };
}
const tokenBalancesWithContractDataCache_sdo = (httpClient) => (state, tokenBalances) => {
  const missingCacheContractDataAddresses = tokenBalances.filter((tb) => !state.contractData.some((cd) => cd.address === tb.address)).map((tb) => tb.address);
  return fetchTokensData(httpClient, missingCacheContractDataAddresses).pipe(
    (0, import_rxjs.mergeMap)(
      (newTokens) => (0, import_rxjs.of)(
        newTokens ? newTokens.concat(state.contractData) : state.contractData
      )
    ),
    (0, import_rxjs.mergeMap)((tokenContractData) => {
      return (0, import_rxjs.of)(
        toTokensWithContractDataFn(tokenBalances)(tokenContractData)
      ).pipe(
        (0, import_rxjs.startWith)(
          toTokensWithContractDataFn(tokenBalances)(state.contractData)
        )
      );
    }),
    (0, import_rxjs.catchError)((err) => {
      console.log(
        "tokenBalancesWithContractDataCache_sdo ERROR=",
        err.message
      );
      return (0, import_rxjs.of)({ tokens: [], contractData: state.contractData });
    }),
    (0, import_rxjs.shareReplay)(1)
  );
};
const resolveEmptyIconUrls = (tokens) => {
  return tokens.map((tkn) => {
    tkn.data.iconUrl = tkn.data.iconUrl ? (0, import_nftUtil.toIpfsProviderUrl)(tkn.data.iconUrl) ?? tkn.data.iconUrl : (0, import_getIconUrl.getIconUrl)(tkn.data.address);
    return tkn;
  });
};
const replaceReefBalanceFromAccount = (tokens, accountBalance) => {
  if (!accountBalance || accountBalance.lte(import_ethers.BigNumber.from("0"))) {
    return tokens;
  }
  const reefTkn = tokens.data.find((t) => t.data.address === import_tokenModel.REEF_ADDRESS);
  if (reefTkn) {
    reefTkn.data.balance = accountBalance;
  }
  return tokens;
};
const loadAccountTokens_sdo = ([
  httpClient,
  signer,
  forceReloadj,
  tokensUpdated
]) => {
  return !signer ? (0, import_rxjs.of)(
    (0, import_statusDataObject.toFeedbackDM)(
      [],
      import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
      "Signer not set"
    )
  ) : (
    // can also be httpClient subscription
    (0, import_gqlUtil.queryGql$)(httpClient, (0, import_signerTokens.getSignerTokensQuery)(signer.data.address)).pipe(
      (0, import_rxjs.map)((res) => {
        if (res?.data?.tokenHolders) {
          return res.data.tokenHolders.map(
            (th) => ({
              address: th.token.id,
              balance: th.balance
            })
          );
        }
        if ((0, import_statusDataObject.isFeedbackDM)(res)) {
          return res;
        }
        throw new Error("No result from SIGNER_TOKENS_GQL");
      }),
      // eslint-disable-next-line camelcase
      (0, import_rxjs.mergeScan)(tokenBalancesWithContractDataCache_sdo(httpClient), {
        tokens: [],
        contractData: [(0, import_tokenUtil2.reefTokenWithAmount)()]
      }),
      (0, import_rxjs.map)(
        (tokens_cd) => resolveEmptyIconUrls(tokens_cd.tokens)
      ),
      (0, import_rxjs.map)(import_tokenUtil.sortReefTokenFirst),
      (0, import_rxjs.map)((tkns) => {
        return (0, import_statusDataObject.toFeedbackDM)(tkns, (0, import_statusDataObject.collectFeedbackDMStatus)(tkns));
      }),
      (0, import_rxjs.catchError)((err) => {
        console.log("loadAccountTokens 1 ERROR=", err);
        return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
      }),
      (0, import_rxjs.shareReplay)(1)
    )
  );
};
const loadAllTokens_sdo = ([httpClient, forceReloadj, tokensUpdated]) => {
  let offset = 0;
  return (0, import_gqlUtil.queryGql$)(httpClient, (0, import_signerTokens.getAllTokensQuery)(offset)).pipe(
    (0, import_rxjs.expand)((res) => {
      if (res.data.tokenHolders && res.data.tokenHolders.length > 0) {
        offset += 320;
        return (0, import_gqlUtil.queryGql$)(httpClient, (0, import_signerTokens.getAllTokensQuery)(offset));
      } else {
        return import_rxjs.EMPTY;
      }
    }),
    (0, import_rxjs.map)((res) => {
      if (res?.data?.tokenHolders) {
        return res.data.tokenHolders.map(
          (th) => ({
            address: th.token.id,
            balance: th.balance
          })
        );
      }
      if ((0, import_statusDataObject.isFeedbackDM)(res)) {
        return res;
      }
      throw new Error("No result from SIGNER_TOKENS_GQL");
    }),
    (0, import_rxjs.scan)((acc, current) => [...acc, ...current], []),
    (0, import_rxjs.mergeScan)(tokenBalancesWithContractDataCache_sdo(httpClient), {
      tokens: [],
      contractData: [(0, import_tokenUtil2.reefTokenWithAmount)()]
    }),
    (0, import_rxjs.map)(
      (tokens_cd) => resolveEmptyIconUrls(tokens_cd.tokens)
    ),
    (0, import_rxjs.map)(import_tokenUtil.sortReefTokenFirst),
    (0, import_rxjs.map)((tkns) => {
      return (0, import_statusDataObject.toFeedbackDM)(tkns, (0, import_statusDataObject.collectFeedbackDMStatus)(tkns));
    }),
    (0, import_rxjs.catchError)((err) => {
      console.log("loadAccountTokens 1 ERROR=", err);
      return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
    }),
    (0, import_rxjs.shareReplay)(1)
  );
};
const setReefBalanceFromAccount = ([tokens, selSigner]) => {
  if (!selSigner) {
    return (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES);
  }
  const signerTkns = tokens ? tokens.data : [];
  if (selSigner.data.balance) {
    const reefT = signerTkns.find((t) => t.data.address === import_tokenModel.REEF_ADDRESS);
    if (reefT) {
      reefT.data.balance = selSigner.data.balance;
    } else {
      signerTkns.unshift(
        (0, import_statusDataObject.toFeedbackDM)(
          {
            ...import_tokenModel.REEF_TOKEN,
            balance: selSigner.data.balance
          },
          import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA
        )
      );
    }
  }
  return (0, import_statusDataObject.toFeedbackDM)(signerTkns, tokens.getStatusList());
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  fetchTokensData,
  loadAccountTokens_sdo,
  loadAllTokens_sdo,
  replaceReefBalanceFromAccount,
  setReefBalanceFromAccount
});
