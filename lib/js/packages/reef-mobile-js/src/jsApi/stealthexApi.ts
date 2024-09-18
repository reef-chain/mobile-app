import axios from "axios";
const baseUrl = "https://api.reefscan.com/stealthex";

const listCurrencies = async () => {
  try {
    const { data } = await axios.request({
      url:`${baseUrl}/listcurrencies`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return data.data;
  } catch (error) {
   console.log("listCurrencies===", error);
    return [];
  }
};


const getExchangeRange = async(
  fromSymbol:string,
  fromNetwork:string,
) =>{
  try {
    const {data} = await axios.request({
      url:`${baseUrl}/exchange-rate/${fromSymbol}/${fromNetwork}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return data.data;
  } catch (error) {
    console.log(error);
    return {
      "min_amount": null,
      "max_amount": null
    }
  }
}

const getEstimatedExchange = async(sourceChain:string,sourceNetwork:string,amount:number)=>{
  try {
    const { data } = await axios.request({
      url:`${baseUrl}/estimated-exchange/${sourceChain}/${sourceNetwork}/${amount}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return data.data;
  } catch (error) {
        return 0;
    }
}

const setTransactionHash = async(id:string,tx_hash:string)=>{
  const options = {
    url:`${baseUrl}/set-tx-hash/`,
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    data: {
      id,tx_hash
    }
  };
  
  try {
    const {data} =  await axios.request(options);
    return data.data;
  } catch (error) {
   console.log("setTransactionHash===",error);
  }
}

const createExchange = async(fromSymbol:string,fromNetwork:string,toSymbol:string,toNetwork:string,amount:number,address:string)=>{
const options = {
  url:`${baseUrl}/create-exchange`,
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  data: {
    fromSymbol,fromNetwork,toSymbol,toNetwork,amount,address
  }
};

try {
  const {data} =  await axios.request(options);
  return data.data;
} catch (error) {
 console.log("createExchange===",error.message);
  return {};
}
}

export default{
    listCurrencies,
    getEstimatedExchange,
    createExchange,
    setTransactionHash,
    getExchangeRange
}