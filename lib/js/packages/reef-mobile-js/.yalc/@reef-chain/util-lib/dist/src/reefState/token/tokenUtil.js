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
var tokenUtil_exports = {};
__export(tokenUtil_exports, {
  sortReefTokenFirst: () => sortReefTokenFirst,
  toPlainString: () => toPlainString,
  toTokensWithPrice_sdo: () => toTokensWithPrice_sdo
});
module.exports = __toCommonJS(tokenUtil_exports);
var import_statusDataObject = require("../model/statusDataObject");
var import_tokenModel = require("../../token/tokenModel");
var import_tokenUtil = require("../../token/tokenUtil");
const toPlainString = (num) => `${+num}`.replace(
  /(-?)(\d*)\.?(\d*)e([+-]\d+)/,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  (a, b, c, d, e) => e < 0 ? `${b}0.${Array(1 - e - c.length).join("0")}${c}${d}` : b + c + d + Array(e - d.length + 1).join("0")
);
const sortReefTokenFirst = (tokens) => {
  const reefTokenIndex = tokens.findIndex(
    (t) => t.data.address === import_tokenModel.REEF_ADDRESS
  );
  if (reefTokenIndex > 0) {
    return [
      tokens[reefTokenIndex],
      ...tokens.slice(0, reefTokenIndex),
      ...tokens.slice(reefTokenIndex + 1, tokens.length)
    ];
  }
  return tokens;
};
const toTokensWithPrice_sdo = ([tokens, reefPrice, pools]) => {
  const tknsWPrice = tokens.data.map((token_sdo) => {
    const isReef = token_sdo.data.address === import_tokenModel.REEF_ADDRESS;
    const returnTkn = (0, import_statusDataObject.toFeedbackDM)(
      {
        ...token_sdo.data,
        price: isReef ? reefPrice.data : 0
      },
      token_sdo.getStatusList()
    );
    if (!isReef && token_sdo.hasStatus(
      import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA
    )) {
      const priceSDO = (0, import_tokenUtil.calculateTokenPrice_sdo)(
        token_sdo.data,
        pools,
        reefPrice
      );
      if (priceSDO) {
        returnTkn.setStatus(
          priceSDO.getStatus().map(
            (priceStat) => ({
              ...priceStat,
              propName: "price"
            })
          )
        );
        returnTkn.data.price = priceSDO.data;
      }
    }
    return returnTkn;
  });
  return (0, import_statusDataObject.toFeedbackDM)(
    tknsWPrice,
    tknsWPrice.length ? (0, import_statusDataObject.collectFeedbackDMStatus)(tknsWPrice) : tokens.getStatusList()
  );
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  sortReefTokenFirst,
  toPlainString,
  toTokensWithPrice_sdo
});
