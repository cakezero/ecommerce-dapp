const trackingNumber = args[0];
const errorCodes = [400, 500, 403, 404, 501]

const DHLResponse = await Functions.makeHttpRequest({
  url: "https://api-eu.dhl.com/track/shipments",
  method: "GET",
  headers: {
    "Content-Type": "application/json",
    'DHL-API-KEY': secrets.apiKey
  },
  params: {trackingNumber}
});

if (DHLResponse.status in errorCodes) {
  throw new Error(JSON.stringify(DHLResponse));
}
console.log(DHLResponse);
// apisecret =  YxAruhlobXocfeX8
//  apikey =  WGa9dGjtdQlCxl0wQouGvbbhcUTZnHNB