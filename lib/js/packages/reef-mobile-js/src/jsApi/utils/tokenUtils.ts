import { Contract } from "ethers";
import { Signer as EvmProviderSigner, Provider} from "@reef-chain/evm-provider";
import { ERC20 } from "../abi/ERC20";
import {graphql, tokenUtil,} from "@reef-chain/util-lib";
import { getPoolReserves } from "./poolUtils";
import {firstValueFrom} from "rxjs";

export const getREEF20Contract = async (address: string, signerOrProvider: EvmProviderSigner): Promise<Contract> => {
    try {
        const contract = new Contract(address, ERC20, signerOrProvider);
        // Check if contract exists and is ERC20
        await contract.name();
        await contract.symbol();
        await contract.decimals();
        return contract;
    } catch (error) {
        throw new Error("Unknown address");
    }
};

export const approveTokenAmount = async (
  tokenAddress: string,
  sellAmount: string,
  routerAddress: string,
  signer: EvmProviderSigner
): Promise<void> => {
  const tokenContract = await getREEF20Contract(tokenAddress, signer);
  if (tokenContract) {
    await tokenContract.approve(routerAddress, sellAmount);
    return;
  }
  throw new Error(`Token contract does not exist addr=${tokenAddress}`);
}

// @ts-ignore
export const fetchTokenData = (
    httpClient: any,
    searchAddress: string,
    provider: Provider,
    factoryAddress: string,
    reefPrice: number
  ): Promise<TokenWithAmount> => /*apollo
    .query({
      query: CONTRACT_DATA_GQL,
      variables: { address: searchAddress },
    })*/
    firstValueFrom(
      graphql.queryGql$(httpClient, graphql.getContractDataQuery([searchAddress])
      )
      )
    .then((verContracts: any) => {
        const vContract = verContracts.data.verifiedContracts[0];
        if (!vContract) return null;

        const token: Token = {
          address: vContract.id,
          iconUrl: vContract.contractData.token_icon_url,
          decimals: vContract.contractData.decimals,
          name: vContract.contractData.name,
          symbol: vContract.contractData.symbol,
        } as Token;

        return toTokenWithPrice(token, reefPrice, provider, factoryAddress);
    })
    .then((tokenWithPrice: TokenWithAmount[]) => tokenWithPrice);

const toTokenWithPrice = async (token: Token, reefPrice: number, provider: Provider, factoryAddress: string): Promise<TokenWithAmount> => {
    return {
        ...token,
        price: await calculateTokenPrice(token.address, reefPrice, provider, factoryAddress),
    } as TokenWithAmount;
}

const calculateTokenPrice = async (
  tokenAddress: string,
  reefPrice: number,
  provider: Provider,
  factoryAddress: string,
  ): Promise<number|null> => {
  if (!reefPrice) {
      return reefPrice;
  }
  let ratio: number;
  if (tokenAddress !== tokenUtil.REEF_ADDRESS.toLowerCase()) {
      const reserves = await getPoolReserves(tokenUtil.REEF_ADDRESS, tokenAddress, provider, factoryAddress);
      if (reserves) {
        ratio = reserves.reserve1 / reserves.reserve2;
        return ratio * (reefPrice as number);
      }
      return null;
  }
  return reefPrice;
};




