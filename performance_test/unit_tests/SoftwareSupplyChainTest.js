function softwareSupplyChainInstance(web3, abi, contractAddress, account, consent, mailDev, group, projectName) {
    const softwareSupplyChain = new web3.eth.Contract(abi, contractAddress);

    async function registerConsent(consent) {
        try {
            const receipt = await softwareSupplyChain.methods.registerConsent(consent).send({ from: account})
            console.log('Consent registered:', receipt);
        } catch (error) {
            console.error('Error registering consent:', error);
        }
    }

    async function addDeveloper(email) {
        try {
            const receipt = await softwareSupplyChain.methods.addDeveloper(email).send({ from: account });
            console.log('Developer added:', receipt);
        } catch (error) {
            console.error('Error adding developer:', error);
        }
    }

    async function createGroup(groupName) {
        try {
            const receipt = await softwareSupplyChain.methods.createGroup(groupName).send({ from: account });
            console.log('Group created:', receipt);
        } catch (error) {
            console.error('Error creating group:', error);
        }
    }

    async function createProject(groupName, projectName) {
        try {
            const receipt = await softwareSupplyChain.methods.createProject(groupName, projectName).send({ from: account });
            console.log('Project created:', receipt);
        } catch (error) {
            console.error('Error creating project:', error);
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
