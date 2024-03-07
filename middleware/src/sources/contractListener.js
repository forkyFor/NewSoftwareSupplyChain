const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, "../../../.env") });
const Web3 = require('web3');
const db = require('./db');

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
   console.log(event);
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
   console.log("blockchain_address" + event.returnValues.id); // same results as the optional callback above
   console.log("email" + event.returnValues.email); // same results as the optional callback above

   const blockchain_address = event.returnValues.id;
   const email = event.returnValues.email;

   const queryText = 'INSERT INTO users(blockchain_address, email) VALUES($1, $2)';
   const queryParams = [blockchain_address, email];

   db.query(queryText, queryParams)
      .then(res => console.log('Developer added to DB:', blockchain_address))
      .catch(e => console.error('Error adding developer to DB:', e.stack));
})
.on('changed', function(event){
    console.log(event); // remove event from local database
})
.on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
    console.log(error); // remove event from local database
});


softwareSupplyChain.events.verifyExistingEmail({
   fromBlock: 'latest'
}).on('data', function(event) {
   
   const requestId = event.returnValues.requestId;
   console.log("request id " + requestId);
   const email = event.returnValues.addressMail;
   const queryText = 'SELECT email FROM users WHERE email = $1';
   const queryParams = [email];

   db.query(queryText, queryParams)
   .then(res => {
         const sendOptions = { from: requestId};
         console.log("request id " + requestId);
         let found = res.rows.length > 0;
        
         softwareSupplyChain.methods.responseVerifyExistingEmail(found,email).send(sendOptions)
               .then(receipt => console.log('Transaction receipt:', receipt))
               .catch(e => console.error('Error sending data back to smart contract:', e));
      })
      .catch(e => console.error('Error adding developer to DB:', e.stack));
   
});