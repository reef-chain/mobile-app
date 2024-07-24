import axios, { AxiosResponse } from "axios";

const explorerApi = axios.create({
    baseURL: 'https://api.reefscan.info',
  });

const coingeckoApi = axios.create({
    baseURL: 'https://api.coingecko.com/api/v3/',
  });

  interface PriceRes {
    [currenty: string]: {
      usd: number;
    };
  }
  
  
const getCoingeckoPrice = (tokenId: string):Promise<number> => coingeckoApi
  .get<void, AxiosResponse<PriceRes>>(
    `/simple/price?ids=${tokenId}&vs_currencies=usd`,
  )
  .then((res) => res.data[tokenId].usd);

export const getReefTokenPrice = async (): Promise<number> => {
    return explorerApi.get<void, AxiosResponse<any>>(
    '/price/reef',
    ).then((res) => res.data.usd).catch(() => getCoingeckoPrice("reef"));
  };