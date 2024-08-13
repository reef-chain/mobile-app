const axios = require('axios').default;

const getOptions = (bearerToken:string,url:string)=>{
    return {
        method: 'GET',
        url,
        headers: {Authorization: `Bearer ${bearerToken}`}
      };
}

const listCurrencies = async(bearerToken:string)=>{
    try {
        const { data } = await axios.request(getOptions(bearerToken,'https://api.stealthex.io/v4/currencies?network=mainnet&limit=250'));
        return data;
    } catch (error) {
        console.error(error);
        return [];
    }
}

export default{
    listCurrencies
}