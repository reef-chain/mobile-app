var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
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
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var nftUtil_exports = {};
__export(nftUtil_exports, {
  getIpfsUrl: () => getIpfsUrl,
  getResolveNftPromise: () => getResolveNftPromise,
  resolveNftImageLinks: () => resolveNftImageLinks,
  resolveNftImageLinks$: () => resolveNftImageLinks$,
  toIpfsProviderUrl: () => toIpfsProviderUrl
});
module.exports = __toCommonJS(nftUtil_exports);
var import_rxjs = require("rxjs");
var import_ethers = require("ethers");
var import_axios = __toESM(require("axios"));
var import_statusDataObject = require("../reefState/model/statusDataObject");
var import_tokenUtil = require("./tokenUtil");
const extractIpfsHash = (ipfsUri) => {
  const ipfsProtocol = "ipfs://";
  if (ipfsUri?.startsWith(ipfsProtocol)) {
    return ipfsUri.substring(ipfsProtocol.length);
  }
  return null;
};
function getIpfsUrl(ipfsHash) {
  return `https://reef.infura-ipfs.io/ipfs/${ipfsHash}`;
}
const toIpfsProviderUrl = (ipfsUriStr, ipfsUrlResolver) => {
  const ipfsHash = extractIpfsHash(ipfsUriStr);
  if (ipfsHash) {
    return !ipfsUrlResolver ? getIpfsUrl(ipfsHash) : ipfsUrlResolver(ipfsHash);
  }
  return null;
};
const resolveUriToUrl = (uri, nft, ipfsUrlResolver) => {
  const ipfsUrl = toIpfsProviderUrl(uri, ipfsUrlResolver);
  if (ipfsUrl) {
    return ipfsUrl;
  }
  const idPlaceholder = "{id}";
  if (nft.nftId != null && uri.indexOf(idPlaceholder) > -1) {
    let replaceValue = nft.nftId;
    try {
      replaceValue = parseInt(nft.nftId, 10).toString(16).padStart(64, "0");
    } catch (e) {
    }
    return uri.replace(idPlaceholder, replaceValue);
  }
  return uri;
};
const resolveImageData = (metadata, nft, ipfsUrlResolver) => {
  const imageUriVal = metadata?.image ? metadata.image : metadata.toString();
  return {
    iconUrl: resolveUriToUrl(imageUriVal, nft, ipfsUrlResolver),
    name: metadata.name,
    mimetype: metadata.mimetype
  };
};
const getResolveNftPromise = async (nft, signer, ipfsUrlResolver) => {
  if (!nft) {
    return Promise.resolve(null);
  }
  try {
    const contractTypeAbi = (0, import_tokenUtil.getContractTypeAbi)(nft.contractType);
    const contract = new import_ethers.Contract(
      nft.address,
      contractTypeAbi,
      signer
    );
    const uriPromise = contractTypeAbi.some((fn) => fn.name === "uri") ? contract.uri(nft.nftId) : contract.tokenURI(nft.nftId).catch((reason) => console.log("error getting contract uri"));
    return await uriPromise.then((metadataUri) => resolveUriToUrl(metadataUri, nft, ipfsUrlResolver)).then(import_axios.default.get).then((jsonStr) => resolveImageData(jsonStr.data, nft, ipfsUrlResolver)).then((nftUri) => ({ ...nft, ...nftUri }));
  } catch (e) {
    console.log("ERROR getResolveNftPromise=", e);
    throw new Error(e.message);
  }
};
const resolveNftImageLinks = (nfts, signer, ipfsUrlResolver) => nfts?.length ? (0, import_rxjs.forkJoin)(
  nfts.map((nft) => getResolveNftPromise(nft, signer, ipfsUrlResolver))
) : (0, import_rxjs.of)([]);
const resolveNftImageLinks$ = (nfts, signer, ipfsUrlResolver) => {
  if (!nfts || !nfts.length || !signer) {
    return (0, import_rxjs.of)([]);
  }
  const resolveObsArr = nfts.map(
    (nft) => (0, import_rxjs.of)(nft).pipe(
      (0, import_rxjs.switchMap)(
        (nft2) => getResolveNftPromise(nft2, signer, ipfsUrlResolver)
      ),
      (0, import_rxjs.map)(
        (resNft) => (0, import_statusDataObject.toFeedbackDM)(resNft, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA, "Url resolved")
      ),
      (0, import_rxjs.catchError)((err) => {
        console.log("ERROR resolving nft img=", err);
        return (0, import_rxjs.of)(
          (0, import_statusDataObject.toFeedbackDM)(
            nft,
            import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
            "Url resolve error.",
            "iconUrl"
          )
        );
      }),
      (0, import_rxjs.startWith)(
        (0, import_statusDataObject.toFeedbackDM)(
          nft,
          import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
          "Resolving url.",
          "iconUrl"
        )
      )
    )
  );
  return (0, import_rxjs.combineLatest)(resolveObsArr);
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getIpfsUrl,
  getResolveNftPromise,
  resolveNftImageLinks,
  resolveNftImageLinks$,
  toIpfsProviderUrl
});
