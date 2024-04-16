const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function testModule(web3, abi, contractAddress, sampleDeveloper) {
    const developerManager = new web3.eth.Contract(abi, contractAddress);

    async function registerDeveloper() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await developerManager.methods.newDeveloper(sampleDeveloper).send({ from: accounts[0] });
            console.log('Developer registered:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error registering developer:', JSON.stringify(error));
        }
    }

    async function voteDeveloper() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await developerManager.methods.voteDeveloper(sampleDeveloper, accounts[1], 10, true).send({ from: accounts[0] });
            console.log('Vote registered for developer:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error voting developer:', JSON.stringify(error));
        }
    }

    registerDeveloper();
    setTimeout(voteDeveloper, 3000);  // Delays voting by 3000 ms to simulate asynchronicity

}

module.exports = testModule;
