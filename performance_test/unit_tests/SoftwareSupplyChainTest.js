const fs = require('fs');
const logFile = fs.openSync('./test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;
console.log = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalLog(...args); };
console.error = (...args) => { fs.writeSync(logFile, `${args.join(' ')}\n`); originalError(...args); };
function softwareSupplyChainInstance(web3, abi, contractAddress, account, consent, mailDev, group, projectName) {
    const softwareSupplyChain = new web3.eth.Contract(abi, contractAddress);

    async function registerConsent(consent) {
        try {
            const receipt = await softwareSupplyChain.methods.registerConsent(consent).send({ from: account})
            console.log('Consent registered:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error registering consent:', JSON.stringify(error));
        }
    }

    async function addDeveloper(email) {
        try {
            const receipt = await softwareSupplyChain.methods.addDeveloper(email).send({ from: account });
            console.log('Developer added:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error adding developer:', JSON.stringify(error));
        }
    }

    async function createGroup(groupName) {
        try {
            const receipt = await softwareSupplyChain.methods.createGroup(groupName).send({ from: account });
            console.log('Group created:', receipt);
        } catch (error) {
            console.error('Error creating group:', JSON.stringify(error));
        }
    }

    async function createProject(groupName, projectName) {
        try {
            const receipt = await softwareSupplyChain.methods.createProject(groupName, projectName).send({ from: account });
            console.log('Project created:', JSON.stringify(receipt));
        } catch (error) {
            console.error('Error creating project:', JSON.stringify(error));
        }
    }

    async function mainTestFlow() {
        await registerConsent(consent);
        await addDeveloper(mailDev);
        await createGroup(group);
        await createProject(group, projectName);

    }

    mainTestFlow(); 

    return {
        registerConsent,
        addDeveloper,
        createGroup,
        createProject
    };
}

module.exports = softwareSupplyChainInstance;

