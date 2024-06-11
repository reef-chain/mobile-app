import { graphql} from '@reef-chain/util-lib';
import { getIconUrl } from './utils/poolUtils';

type PoolQueryObject = {query: string, variables: any};

const ALL_POOLS = `
  query allPools {
    allPools {
      address
      decimals1
      decimals2
      reserved1
      reserved2
      symbol1
      symbol2
      token1
      token2
      name1
      name2
      iconUrl1
      iconUrl2
    }
  }
`;

const getAllPoolsQuery = (): PoolQueryObject => ({
    query: ALL_POOLS,
    variables: {},
});

export const fetchAllPools = async ()=>{
    try {

        const response = await fetch('https://squid.subsquid.io/reef-swap-testnet/graphql', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(getAllPoolsQuery()),
          });
      
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
      
          const {data} = await response.json();
          const pools = data.allPools.map((pool) => ({
            ...pool,
            iconUrl1: pool.iconUrl1 === '' ? getIconUrl(pool.token1) : pool.iconUrl1,
            iconUrl2: pool.iconUrl2 === '' ? getIconUrl(pool.token2) : pool.iconUrl2,
          }));
          console.log("data===",pools);
          return pools;
    } catch (error) {
        console.log(error);
        return [];
    }
}