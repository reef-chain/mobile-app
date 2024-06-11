import { graphql} from '@reef-chain/util-lib';
import { getIconUrl } from './utils/poolUtils';


const getAllPoolsQuery = (limit:number,offset:number,search:string,signerAddress:string) => {
  return {
    query: `
    query allPoolsList {
      allPoolsList(limit: ${limit}, offset: ${offset}, search: "${search}", signerAddress: "${signerAddress}") {
        id
        iconUrl1
        iconUrl2
        name1
        name2
        prevDayVolume1
        prevDayVolume2
        reserved1
        symbol1
        dayVolume1
        dayVolume2
        decimals1
        decimals2
        reserved2
        symbol2
        token1
        token2
        userLockedAmount1
        userLockedAmount2
      }
    }
    `
}};

export const fetchAllPools = async (limit:number,offset:number,search:string,signerAddress:string)=>{
    try {

        const response = await fetch('https://squid.subsquid.io/reef-swap-testnet/graphql', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(getAllPoolsQuery(limit,offset,search,signerAddress)),
          });
      
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
      
          const {data} = await response.json();
          const pools = data.allPoolsList.map((pool) => ({
            ...pool,
            iconUrl1: pool.iconUrl1 === '' ? getIconUrl(pool.token1) : pool.iconUrl1,
            iconUrl2: pool.iconUrl2 === '' ? getIconUrl(pool.token2) : pool.iconUrl2,
          }));
          return pools;
    } catch (error) {
        console.log(error);
        return [];
    }
}