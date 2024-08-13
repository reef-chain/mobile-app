const axios = require('axios').default;

const getOptions = (bearerToken:string,url:string)=>{
    return {
        method: 'GET',
        url,
        headers: {Authorization: `Bearer ${bearerToken}`}
      };
}

const listExchanges = async(bearerToken:string)=>{
    try {
        const { data } = await axios.request(getOptions(bearerToken,'https://api.stealthex.io/v4/currencies/'));
        console.log(data);
    } catch (error) {
        console.error(error);
    }
}

export default{
    listExchanges
}