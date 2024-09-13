const baseUrl = "https://api.reefscan.com/stealthex";

const listCurrencies = async () => {
  try {
    const response = await fetch(`${baseUrl}/listcurrencies`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data } = await response.json();
    return data;
  } catch (error) {
    console.error("listCurrencies===", error);
    return [];
  }
};


const getExchangeRange = async(
  fromSymbol:string,
  fromNetwork:string,
) =>{
  try {
    const response = await fetch(`${baseUrl}/exchange-rate/${fromSymbol}/${fromNetwork}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data } = await response.json();
    return data;
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
    const response = await fetch(`${baseUrl}/estimated-exchange/${sourceChain}/${sourceNetwork}/${amount}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data } = await response.json();
    return data;
  } catch (error) {
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