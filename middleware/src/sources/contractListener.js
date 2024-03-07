const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, "../../../.env") });
const Web3 = require('web3');

const pathFromEnv = process.env.PATH_ABI_JSON; // './abi.json'
const contractABI = require(path.resolve(__dirname, "../../..",pathFromEnv));
const contractAddress = process.env.CONTRACT_ADDRESS; 

var web3 = new Web3(new Web3.providers.WebsocketProvider(process.env.BLOCKCHAIN_ADDRESS_WS));

const softwareSupplyChain = new web3.eth.Contract(contractABI, contractAddress);

softwareSupplyChain.events.LogData({
    fromBlock: 'latest'
}, function(error, event){ console.log(event); })
.on("connected", function(subscriptionId){
   console.log(subscriptionId);
})
.on('data', function(event){
   console.log(event); // same results as the optional callback above
})
.on('changed', function(event){
   // remove event from local database
})
.on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
   // remove event from local database
});


softwareSupplyChain.events.DeveloperAdded({
   fromBlock: 'latest'
}, function(error, event){ console.log(error); console.log(event); })
.on("connected", function(subscriptionId){
   console.log(subscriptionId);
})
.on('data', function(event){
   console.log(event); // same results as the optional callback above
})
.on('changed', function(event){
    console.log(event); // remove event from local database
})
.on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
    console.log(error); // remove event from local database
});
