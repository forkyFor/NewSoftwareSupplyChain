const Web3 = require('web3');
const fs = require('fs');
const path = require('path');
const solc = require('solc');
require('dotenv').config({ path: '../.env' });
const createConsentManager = require('./consentTest');

// Set up web3 provider
var web3 = new Web3(new Web3.providers.WebsocketProvider(process.env.BLOCKCHAIN_ADDRESS_WS));
const sampleAddress = '....'; // Replace with actual Ethereum address

// Compile the Solidity contract
function compileContract() {
    const contractPath = path.resolve(__dirname, '../contracts', 'ConsentManager.sol');
    const contractSource = fs.readFileSync(contractPath, 'utf8');

    const input = {
        language: 'Solidity',
        sources: {
            'ConsentManager.sol': {
                content: contractSource,
            },
        },
        settings: {
            outputSelection: {
                '*': {
                    '*': ['*']
                }
            }
        }
    };

    const output = JSON.parse(solc.compile(JSON.stringify(input)));
    fs.writeFileSync(path.resolve(__dirname, './build/ConsentManager.json'), JSON.stringify(output.contracts['ConsentManager.sol'].ConsentManager));
    return output.contracts['ConsentManager.sol'].ConsentManager;
}

const { abi, evm } = compileContract();
const contractAddress = process.env.consent_manager_address;

// Create contract instance
const consentManager = createConsentManager(web3, abi, contractAddress);
consentManager.registerConsent(sampleAddress, 'Y'); // Registering consent

setTimeout(() => {
    consentManager.checkConsent(sampleAddress); // Checking consent
  }, 3000);






