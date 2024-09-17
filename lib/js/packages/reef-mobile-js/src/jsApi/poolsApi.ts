import { reefState,tokenIconUtils,tokenPriceUtils,tokenUtil } from '@reef-chain/util-lib';
import BigNumber from 'bignumber.js';
import { getIconUrl } from './utils/poolUtils';
import { firstValueFrom, skipWhile } from 'rxjs';
import { getDexUrl } from './utils/networkUtils';
import { BigNumber as BN } from 'bignumber.js';

const getAllPoolsQuery = (limit: number, offset: number, search: string, signerAddress: string) => {
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
  }
};

const getPoolPairsQuery = (tokenAddr, limit, offset) => {
  return {
    query: `
    query PoolPairs {
  pools(limit:${limit},offset:${offset},where: {token1: {id_eq: "${tokenAddr}"}, OR: {token2: {id_eq: "${tokenAddr}"}}}) {
    token1 {
      id
      name
      symbol
      iconUrl
      decimals
    }
    token2 {
      id
      iconUrl
      decimals
      name
      symbol
    }
  }
}
    `
  }
};

const getPoolTotalValueLockedQry = (toTime: string): any => ({
  query: `
  query totalSupply($toTime: String!) {
    totalSupply(toTime: $toTime) {
      pool {
        address
        token1
        token2
      }
      reserved1
      reserved2
    }
  }
`,
  variables: { toTime },
});

const getTokenInfoQuery = (tokenAddr:string) => {
  return {
    query: `
    query TokenQuery {
        tokens(where: {id_containsInsensitive: "${tokenAddr}"}, limit: 1) {
          decimals
          iconUrl
          id
          name
          symbol
        }
      }
    `
  }
};

const calculateUSDTVL = ({
  reserved1,
  reserved2,
  decimals1,
  decimals2,
  token1,
  token2,
}, tokenPrices: any): string => {
  const r1 = new BigNumber(reserved1).div(new BigNumber(10).pow(decimals1)).multipliedBy(tokenPrices[token1] || 0);
  const r2 = new BigNumber(reserved2).div(new BigNumber(10).pow(decimals2)).multipliedBy(tokenPrices[token2] || 0);
  const result = r1.plus(r2).toFormat(2);
  return result === 'NaN' ? '0' : result;
};

const calculate24hVolumeUSD = ({
  token1,
  token2,
  dayVolume1,
  dayVolume2,
  prevDayVolume1,
  prevDayVolume2,
  decimals1,
  decimals2,
}: any,
  tokenPrices: any,
  current: boolean): BigNumber => {
  const v1 = current ? dayVolume1 : prevDayVolume1;
  const v2 = current ? dayVolume2 : prevDayVolume2;
  if (v1 === null && v2 === null) return new BigNumber(0);
  const dv1 = new BigNumber(v1 === null ? 0 : v1)
    .div(new BigNumber(10).pow(decimals1))
    .multipliedBy(tokenPrices[token1]);
  const dv2 = new BigNumber(v2 === null ? 0 : v2)
    .div(new BigNumber(10).pow(decimals2))
    .multipliedBy(tokenPrices[token2]);

  return dv1.plus(dv2);
};

const calculateVolumeChange = (pool: any, tokenPrices: any): number => {
  const current = calculate24hVolumeUSD(pool, tokenPrices, true);
  const previous = calculate24hVolumeUSD(pool, tokenPrices, false);
  if (previous.eq(0) && current.eq(0)) return 0;
  if (previous.eq(0)) return 100;
  if (current.eq(0)) return -100;
  const res = current.minus(previous).div(previous).multipliedBy(100);
  return res.toNumber();
};

const getTokenPrice = (address: string, prices: any): BN => new BN(
  prices[address] && !Number.isNaN(prices[address])
    ? prices[address]
    : 0,
);

let tvl = '0';

export const getMarketCap = ()=>{
  return tvl;
}

export const fetchAllPools = async (limit: number, offset: number, search: string, signerAddress: string) => {
  try {
    const selectedNw = await firstValueFrom(reefState.selectedNetwork$);
    let {data:reefPrice} = await firstValueFrom(tokenUtil.reefPrice$.pipe(skipWhile(
      value =>
        !value.hasStatus(reefState.FeedbackStatusCode.COMPLETE_DATA) ||
        value.getStatusList().length != 1
    )));

    let tokenPrices = {
      "0x0000000000000000000000000000000001000000" : reefPrice
    };

    const response = await fetch(getDexUrl(selectedNw.name), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(getAllPoolsQuery(limit, offset, search, signerAddress)),
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data } = await response.json();

    tokenPriceUtils.calculateTokenPrices(data.allPoolsList,tokenPrices);

    const toTime = new Date();

    const marketCapResponse = await fetch(getDexUrl(selectedNw.name), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(getPoolTotalValueLockedQry(toTime.toISOString())),
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data:marketCapData } = await marketCapResponse.json();
    
    if (!marketCapData || marketCapData.totalSupply.length === 0) {
      tvl= '0';
    }
  
    const totalSupply = marketCapData.totalSupply.reduce((acc, { reserved1, reserved2, pool: { token1, token2 } }) => {
      const tokenPrice1 = getTokenPrice(token1, tokenPrices);
      const tokenPrice2 = getTokenPrice(token2, tokenPrices);
      const r1 = tokenPrice1.multipliedBy(new BigNumber(reserved1).div(new BigNumber(10).pow(18)));
      const r2 = tokenPrice2.multipliedBy(new BigNumber(reserved2).div(new BigNumber(10).pow(18)));
      return acc.plus(r1).plus(r2);
    }, new BigNumber(0));
  
    tvl = parseFloat(totalSupply.toString()).toFixed(4).toString();

    let tokenAddresess = [];

    for (let i = 0; i < data.allPoolsList.length; i++) {
      if (!tokenAddresess.includes(data.allPoolsList[i].token1)) {
        tokenAddresess.push(data.allPoolsList[i].token1);
      }
      if (!tokenAddresess.includes(data.allPoolsList[i].token2)) {
        tokenAddresess.push(data.allPoolsList[i].token2);
      }
    }

    const tokenIconMap = await tokenIconUtils.resolveTokenUrl(tokenAddresess);

    const pools = data.allPoolsList.map((pool) => ({
      ...pool,
      iconUrl1: pool.iconUrl1 === '' ? tokenIconMap[pool.token1] != '' && tokenIconMap[pool.token1] ? tokenIconMap[pool.token1] : getIconUrl(pool.token1) : pool.iconUrl1,
      iconUrl2: pool.iconUrl2 === '' ? tokenIconMap[pool.token2] != '' && tokenIconMap[pool.token2] ? tokenIconMap[pool.token2] : getIconUrl(pool.token2) : pool.iconUrl2,
      tvl: calculateUSDTVL({ reserved1: pool.reserved1, reserved2: pool.reserved2, decimals1: pool.decimals1, decimals2: pool.decimals2, token1: pool.token1, token2: pool.token2 }, tokenPrices),
      volume24h: calculate24hVolumeUSD(pool, tokenPrices, true).toFormat(2),
      volumeChange24h: calculateVolumeChange(pool, tokenPrices),
    }));
    return pools;
  } catch (error) {
    console.log(error);
    return [];
  }
}

export const getPoolPairs = async (tokenAddr: string) => {
  try {
    const selectedNw = await firstValueFrom(reefState.selectedNetwork$);
    let limit = 70;
    let offset = 0;
    const response = await fetch(getDexUrl(selectedNw.name), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(getPoolPairsQuery(tokenAddr, limit, offset)),
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    const { data } = await response.json();

    const pools = data.pools.map((pool) => {
      if (pool['token1'].id == tokenAddr) {
        return {
          address: pool['token2']['id'],
          name: pool['token2']['name'],
          symbol: pool['token2']['symbol'],
          iconUrl: pool['token2']['iconUrl'] == "" ? getIconUrl(pool['token2']['id']) : pool['token2']['iconUrl'],
          decimals: pool['token2']['decimals']
        }
      } else {
        return {
          address: pool['token1']['id'],
          name: pool['token1']['name'],
          symbol: pool['token1']['symbol'],
          iconUrl: pool['token1']['iconUrl'] == "" ? getIconUrl(pool['token1']['id']) : pool['token1']['iconUrl'],
          decimals: pool['token1']['decimals']
        }
      }
    })

    return pools;
  } catch (error) {
    console.log(error);
    return [];
  }
}

export const getTokenInfo = async (tokenAddr: string) => {
  try {
    const selectedNw = await firstValueFrom(reefState.selectedNetwork$);
    const response = await fetch(getDexUrl(selectedNw.name), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(getTokenInfoQuery(tokenAddr)),
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    const { data } = await response.json();

    let tokenAddresess = [];

    for (let i = 0; i < data.tokens.length; i++) {
      if (!tokenAddresess.includes(data.tokens[i].id)) {
        tokenAddresess.push(data.tokens[i].id);
      }
    }

    const tokenIconMap = await tokenIconUtils.resolveTokenUrl(tokenAddresess);


    let token;
    if (data.tokens.length) {
      token = {
        ...data.tokens[0],
        address: data.tokens[0].id,
        iconUrl: data.tokens[0]['iconUrl'] == '' ?tokenIconMap[data.tokens[0].id]!='' && tokenIconMap[data.tokens[0].id]? tokenIconMap[data.tokens[0].id]: getIconUrl(data.tokens[0]['id']) : data.tokens[0]['iconUrl']
      };
    }
    return token;
  } catch (error) {
    console.log(error);
    return [];
  }
}