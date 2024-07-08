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
var rpc_exports = {};
__export(rpc_exports, {
  balanceOf: () => balanceOf,
  checkIfERC20ContractExist: () => checkIfERC20ContractExist,
  contractToToken: () => contractToToken,
  getREEF20Contract: () => getREEF20Contract,
  getReefswapFactory: () => getReefswapFactory,
  getReefswapRouter: () => getReefswapRouter
});
module.exports = __toCommonJS(rpc_exports);
var import_ethers = require("ethers");
var import_ERC20 = require("../token/abi/ERC20");
var import_ReefswapRouter = require("../token/abi/ReefswapRouter");
var import_ReefswapFactory = require("../token/abi/ReefswapFactory");
var import_tokenUtil = require("../token/tokenUtil");
const checkIfERC20ContractExist = async (address, signer) => {
  try {
    const contract = new import_ethers.Contract(
      address,
      import_ERC20.ERC20,
      signer
    );
    const name = await contract.name();
    const symbol = await contract.symbol();
    const decimals = await contract.decimals();
    return { name, symbol, decimals };
  } catch (error) {
    throw new Error("Unknown address");
  }
};
const getREEF20Contract = async (address, signer) => {
  try {
    const values = await checkIfERC20ContractExist(address, signer);
    if (values) {
      return {
        contract: new import_ethers.Contract(
          address,
          import_ERC20.ERC20,
          signer
        ),
        values
      };
    }
  } catch (err) {
  }
  return null;
};
const contractToToken = async (tokenContract, signer) => {
  const contractToken = (0, import_tokenUtil.createEmptyToken)();
  contractToken.address = tokenContract.address;
  contractToken.name = await tokenContract.name();
  contractToken.symbol = await tokenContract.symbol();
  contractToken.balance = await tokenContract.balanceOf(signer.evmAddress);
  contractToken.decimals = await tokenContract.decimals();
  return contractToken;
};
const balanceOf = async (address, balanceAddress, signer) => {
  const contract = (await getREEF20Contract(address, signer))?.contract;
  return contract ? contract.balanceOf(balanceAddress) : null;
};
const getReefswapRouter = (address, signer) => new import_ethers.Contract(address, import_ReefswapRouter.ReefswapRouter, signer);
const getReefswapFactory = (address, signer) => new import_ethers.Contract(address, import_ReefswapFactory.ReefswapFactory, signer);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  balanceOf,
  checkIfERC20ContractExist,
  contractToToken,
  getREEF20Contract,
  getReefswapFactory,
  getReefswapRouter
});
