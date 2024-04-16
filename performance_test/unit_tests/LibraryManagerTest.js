const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function testModule(web3, abi, contractAddress, account, sampleLibraryCID, project, version, dependencies) {
    const libraryManager = new web3.eth.Contract(abi, contractAddress);

    async function addLibrary() {
        try {
            const receipt = await libraryManager.methods.addLibrary(project, sampleLibraryCID, version, dependencies, 10).send({ from: account });
            console.log('Library added:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error adding library:', JSON.stringify(error));
        }
    }

    async function reportMalicious() {
        try {
            const receipt = await libraryManager.methods.reportLibraryMalicious(sampleLibraryCID, account).send({ from: account });
            console.log('Library reported as malicious:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error reporting library:', JSON.stringify(error));
        }
    }

    addLibrary();
    setTimeout(reportMalicious, 3000);  // Report the library as malicious after adding it

}

module.exports = testModule;
