const axios = require('axios').default;

const getOptions = (bearerToken:string,method:string,url:string,data:any)=>{
    return {
        method,
        url,
        headers: {Authorization: `Bearer ${bearerToken}`},
        data
      };
}

const baseUrl = "http://localhost:3002/stealthex";

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
    console.log("listCurrencies===", error.message);
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

const getEstimatedExchange = async(bearerToken:string,sourceChain:string,sourceNetwork:string,amount:number)=>{
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

const setTransactionHash = async(id:string,tx_hash:string)=>{
  try {
    const response = await fetch(`${baseUrl}/set-tx-hash`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body:JSON.stringify({
        id,tx_hash
      })
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const { data } = await response.json();
    return data;
  } catch (error) {
      console.log("setTransactionHash error===",error);
    }
}

const createExchange = async(fromSymbol:string,fromNetwork:string,toSymbol:string,toNetwork:string,amount:number,address:string)=>{
  try {
    const response = await fetch(`${baseUrl}/set-tx-hash`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body:JSON.stringify({
        fromSymbol,fromNetwork,toSymbol,toNetwork,amount,address
      })
    });

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    const { data } = await response.json();
    return data;
  } catch (error) {
  console.log("createExchange===",error);
}
}

export default{
    listCurrencies,
    getEstimatedExchange,
    createExchange,
    setTransactionHash,
    getExchangeRange
}