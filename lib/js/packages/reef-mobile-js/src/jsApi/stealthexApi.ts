const axios = require('axios').default;

const baseUrl = "https://api.stealthex.io/v4";

const getOptions = (bearerToken:string,method:string,url:string,data:any)=>{
    return {
        method,
        url,
        headers: {Authorization: `Bearer ${bearerToken}`},
        data
      };
}

const checkIfReefRouteExists=(availableRoutes:[{symbol:string,network:string}])=>{
  let doesRouteExist = false;
  availableRoutes.forEach((route)=>{
    if(route.symbol=="reef" && route.network=="mainnet"){
      doesRouteExist=true;
    }
  });
  return doesRouteExist;
}

const listCurrencies = async (bearerToken: string) => {
  try {
    const { data } = await axios.request(getOptions(bearerToken, 'GET', `${baseUrl}/currencies?include_available_routes=true&limit=250&network=mainnet`, {}));
    let reefNetwork = [];

    // Finding all routes for reef network
    data.forEach((val) => {
      if (val["symbol"] === "reef") {
        reefNetwork = val.available_routes;
      }
    });

    // Map for tracking the currency symbols
    let availableNetworkRoutesMap = {};

    reefNetwork.forEach((val) => {
      if (availableNetworkRoutesMap[val.network]) {
        availableNetworkRoutesMap[val.network].push(val.symbol);
      } else {
        availableNetworkRoutesMap[val.network] = [val.symbol];
      }
    });

    let res = [];

    data.forEach((val) => {
      if (availableNetworkRoutesMap[val.network] && availableNetworkRoutesMap[val.network].indexOf(val.symbol) !== -1) {
        res.push(val);
      }
    });

    res = res.filter((v) => checkIfReefRouteExists(v["available_routes"]));

    res.sort((a, b) => {
      if (a.symbol === "eth") return -1;
      if (b.symbol === "eth") return 1;
      if (a.symbol === "bnb") return -1;
      if (b.symbol === "bnb") return 1;
      return 0;
    });

    return res;
  } catch (error) {
    console.error("listCurrencies===", error);
    return [];
  }
};


const getExchangeRange = async(
  bearerToken:string,
  fromSymbol:string,
  fromNetwork:string,
) =>{
  try {
    const { data } = await axios.request(getOptions(bearerToken,'POST',`${baseUrl}/rates/range`,{
    route: {
      from: {symbol: fromSymbol, network: fromNetwork},
      to: {symbol: 'reef', network: 'mainnet'}
    },
    estimation: 'direct',
    rate: 'floating'
  }));
    return data;
  } catch (error) {
    console.error(error);
    return {
      "min_amount": null,
      "max_amount": null
    }
  }
}

const getEstimatedExchange = async(bearerToken:string,sourceChain:string,sourceNetwork:string,amount:number)=>{
    console.log(sourceChain,sourceNetwork,amount);
    try {
        const { data } = await axios.request(getOptions(bearerToken,'POST',`${baseUrl}/rates/estimated-amount`,{
            route: {
              from: {symbol: sourceChain, network: sourceNetwork},
              to: {symbol: 'reef', network: 'mainnet'}
            },
            estimation: 'direct',
            rate: 'floating',
            amount
          }));
          console.log("getEstimatedExchange===",data);
        return data.estimated_amount;
    } catch (error) {
        console.log("getEstimatedExchange error===",sourceChain,sourceNetwork,error);
        return 0;
    }
}

const setTransactionHash = async(bearerToken:string,id:string,tx_hash:string)=>{
    const options = {
      method: 'PATCH',
      url: `${baseUrl}/exchanges/${id}`,
      headers: {'Content-Type': 'application/json', Authorization: `Bearer ${bearerToken}`},
      data: {tx_hash}
    };
    
    try {
      const { data } = await axios.request(options);
      console.log("setTransactionHash===",data);
      return data;
    } catch (error) {
      console.error("setTransactionHash error===",error);
    }
}

const createExchange = async(bearerToken:string,fromSymbol:string,fromNetwork:string,toSymbol:string,toNetwork:string,amount:number,address:string)=>{
const options = {
  method: 'POST',
  url: `${baseUrl}/exchanges/`,
  headers: {'Content-Type': 'application/json', Authorization: `Bearer ${bearerToken}`},
  data: {
    route: {
      from: {symbol: fromSymbol, network: fromNetwork},
      to: {symbol: toSymbol, network: toNetwork}
    },
    amount: amount,
    estimation: 'direct',
    rate: 'floating',
    address
  }
};

try {
  const { data } = await axios.request(options);
  console.log("createExchange===",data)
  return data;
} catch (error) {
  console.error("createExchange===",error);
}
}

export default{
    listCurrencies,
    getEstimatedExchange,
    createExchange,
    setTransactionHash,
    getExchangeRange
}