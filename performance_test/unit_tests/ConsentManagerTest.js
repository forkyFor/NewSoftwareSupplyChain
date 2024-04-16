const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function testModule(web3, abi, sampleAddress) {
    
    const contractAddress = process.env.consent_manager_address;
    const consentManager = new web3.eth.Contract(abi, contractAddress);

    async function registerConsent(address, consent) {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await consentManager.methods.registerConsent(address, consent).send({ from: accounts[0] });
            console.log('Transaction receipt:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error registering consent:', JSON.stringify(error));
        }
    }

    async function checkConsent(address) {
        try {
            const isConsented = await consentManager.methods.getConsent(address).call();
            console.log(`Consent status for ${address}: ${isConsented}`);
        } catch (error) {
            console.error('Error checking consent:', JSON.stringify(error));
        }
    }
    
    registerConsent(sampleAddress, 'Y'); // Registering consent

    setTimeout(() => {
        checkConsent(sampleAddress); // Checking consent
      }, 3000);
}

module.exports = testModule;

