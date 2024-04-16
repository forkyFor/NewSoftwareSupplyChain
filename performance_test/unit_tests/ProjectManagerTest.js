const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function testModule(web3, abi, contractAddress, sampleProject, adminAddress, group) {
    const projectManager = new web3.eth.Contract(abi, contractAddress);

    async function addProject() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await projectManager.methods.addProject(sampleProject, adminAddress, "", group).send({ from: adminAddress });
            console.log('Project added:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error adding project:', JSON.stringify(error));
        }
    }

    addProject();

}

module.exports = testModule;
