const axios = require('axios');

let response = null;
new Promise(async (resolve, reject) => {
  try {
    // https://pro-api.coinmarketcap.com/v2/cryptocurrency/info
    response = await axios.get('https://pro-api.coinmarketcap.com/v2/cryptocurrency/market-pairs/latest', {
      headers: {
        'X-CMC_PRO_API_KEY': '5065fb18-debb-4c7c-8a08-2a4b92b8a4d2',
      },
    });
  } catch(ex) {
    response = null;
    // error
    console.log(ex);
    reject(ex);
  }
  if (response) {
    // success
    const json = response.data;
    console.log(json.data[1]);
    resolve(json);
  }
});