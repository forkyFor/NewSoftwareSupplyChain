const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function testModule(web3, abi, contractAddress, adminAddress, sampleGroup ) {
    const groupManager = new web3.eth.Contract(abi, contractAddress);

    async function addGroup() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await groupManager.methods.addDeveloperGroup(sampleGroup, adminAddress).send({ from: accounts[0] });
            console.log('Group added:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error adding group:', JSON.stringify(error));
        }
    }

    async function requestAccess() {
        try {
            const receipt = await groupManager.methods.requestGroupAccess(sampleGroup, adminAddress).send({ from: adminAddress });
            console.log('Access requested for group:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error requesting access:', JSON.stringify(error));
        }
    }

    addGroup();
    setTimeout(requestAccess, 3000);  // Requests access after group is added

}

module.exports = testModule;

