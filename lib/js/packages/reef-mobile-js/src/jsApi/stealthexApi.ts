const axios = require('axios').default;

const getOptions = (bearerToken:string,method:string,url:string,data:any)=>{
    return {
        method,
        url,
        headers: {Authorization: `Bearer ${bearerToken}`},
        data
      };
}

const listCurrencies = async(bearerToken:string)=>{
    try {
        const { data } = await axios.request(getOptions(bearerToken,'GET','https://api.stealthex.io/v4/currencies?include_available_routes=true&limit=250&network=mainnet',{}));
        let reefNetwork = [];

        // finding all routes for reef network
        data.forEach((val)=>{
            if(val["symbol"]=="reef"){
                reefNetwork=val.available_routes;
            }
        })

        // made a map for tracking the currency symbols
        let availableNetworkRoutesMap = {};

        reefNetwork.forEach((val)=>{
            if(availableNetworkRoutesMap[val.network]){
                availableNetworkRoutesMap[val.network].push(val.symbol);
            }else{
                availableNetworkRoutesMap[val.network] = [val.symbol];
            }
        })


        let res=[];

        data.forEach((val)=>{
            if(availableNetworkRoutesMap[val.network] && availableNetworkRoutesMap[val.network].indexOf(val.symbol)){
                res.push(val);
            }
        })

        return res;
    } catch (error) {
        console.error("listCurrencies===",error);
        return [];
    }
}

const getEstimatedExchange = async(bearerToken:string,sourceChain:string,sourceNetwork:string,amount:number)=>{
    try {
        const { data } = await axios.request(getOptions(bearerToken,'POST','https://api.stealthex.io/v4/rates/estimated-amount',{
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

const createExchange = async(bearerToken:string,fromSymbol:string,fromNetwork:string,toSymbol:string,toNetwork:string,amount:number,address:string)=>{
const options = {
  method: 'POST',
  url: 'https://api.stealthex.io/v4/exchanges/',
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
    createExchange
}