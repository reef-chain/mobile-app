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
var pools_exports = {};
__export(pools_exports, {
  fetchPools$: () => fetchPools$,
  loadPool: () => loadPool
});
module.exports = __toCommonJS(pools_exports);
var import_ethers = require("ethers");
var import_rpc = require("../network/rpc");
var import_tokenModel = require("../token/tokenModel");
var import_ReefswapPair = require("../token/abi/ReefswapPair");
var import_rxjs = require("rxjs");
var import_statusDataObject = require("../reefState/model/statusDataObject");
var import_utils = require("../utils/utils");
const findPoolTokenAddress = async (address1, address2, signer, factoryAddress) => {
  const reefswapFactory = (0, import_rpc.getReefswapFactory)(factoryAddress, signer);
  const address = await reefswapFactory.getPair(address1, address2);
  return address;
};
const loadPool = async (token1, token2, signer, factoryAddress) => {
  const address = await findPoolTokenAddress(
    token1.address,
    token2.address,
    signer,
    factoryAddress
  );
  (0, import_utils.ensure)(address !== import_tokenModel.EMPTY_ADDRESS, "Pool does not exist!");
  const contract = new import_ethers.Contract(
    address,
    import_ReefswapPair.ReefswapPair,
    signer
  );
  const decimals = await contract.decimals();
  const reserves = await contract.getReserves();
  const totalSupply = await contract.totalSupply();
  const liquidity = await contract.balanceOf(await signer.getAddress());
  const address1 = await contract.token1();
  const [finalReserve1, finalReserve2] = token1.address !== address1 ? [reserves[0], reserves[1]] : [reserves[1], reserves[0]];
  const tokenBalance1 = finalReserve1.mul(liquidity).div(totalSupply);
  const tokenBalance2 = finalReserve2.mul(liquidity).div(totalSupply);
  return {
    poolAddress: address,
    decimals: parseInt(decimals, 10),
    reserve1: finalReserve1.toString(),
    reserve2: finalReserve2.toString(),
    totalSupply: totalSupply.toString(),
    userPoolBalance: liquidity.toString(),
    token1: { ...token1, balance: tokenBalance1 },
    token2: { ...token2, balance: tokenBalance2 }
  };
};
const cachePool$ = /* @__PURE__ */ new Map();
const poolsRefresh$ = (0, import_rxjs.timer)(0, 42e4);
function isPoolCached(token1, token2) {
  return cachePool$.has(`${token1.address}-${token2.address}`) || cachePool$.has(`${token1.address}-${token2.address}`);
}
const getPool$ = (token1, signer, factoryAddress) => {
  const token2 = import_tokenModel.REEF_TOKEN;
  if (!isPoolCached(token1, token2)) {
    const pool$ = poolsRefresh$.pipe(
      (0, import_rxjs.switchMap)(() => loadPool(token1, token2, signer, factoryAddress)),
      (0, import_rxjs.map)((pool) => (0, import_statusDataObject.toFeedbackDM)(pool, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)),
      (0, import_rxjs.catchError)((err) => {
        return (0, import_rxjs.of)(
          (0, import_statusDataObject.toFeedbackDM)(
            {
              token1,
              token2
            },
            import_statusDataObject.FeedbackStatusCode.ERROR,
            "Loading pool error:" + err.message
          )
        );
      }),
      (0, import_rxjs.shareReplay)(1),
      (0, import_rxjs.startWith)(
        (0, import_statusDataObject.toFeedbackDM)(
          { token1, token2 },
          import_statusDataObject.FeedbackStatusCode.LOADING,
          "Loading pool data."
        )
      )
    );
    cachePool$.set(`${token1.address}-${token2.address}`, pool$);
  }
  return cachePool$.get(`${token1.address}-${token2.address}`) || cachePool$.get(`${token2.address}-${token1.address}`);
};
const fetchPools$ = (tokens, signer, factoryAddress) => {
  const poolsArr$ = tokens.filter((tkn) => tkn.data.address !== import_tokenModel.REEF_ADDRESS).map((tkn) => {
    if (tkn.hasStatus(import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)) {
      return getPool$(tkn.data, signer, factoryAddress);
    }
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)(null, tkn.getStatusList()));
  });
  return (0, import_rxjs.combineLatest)(poolsArr$).pipe((0, import_rxjs.shareReplay)(1));
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  fetchPools$,
  loadPool
});
