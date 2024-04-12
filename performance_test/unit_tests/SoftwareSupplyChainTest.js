function createSoftwareSupplyChainTest(web3, abi, contractAddress, accounts) {
    const softwareSupplyChain = new web3.eth.Contract(abi, contractAddress);

    async function registerConsent(consent) {
        try {
            const receipt = await softwareSupplyChain.methods.registerConsent(consent).send({ from: accounts[0] });
            console.log('Consent registered:', receipt);
        } catch (error) {
            console.error('Error registering consent:', error);
        }
    }

    async function addDeveloper(email) {
        try {
            const receipt = await softwareSupplyChain.methods.addDeveloper(email).send({ from: accounts[0] });
            console.log('Developer added:', receipt);
        } catch (error) {
            console.error('Error adding developer:', error);
        }
    }

    async function createGroup(groupName) {
        try {
            const receipt = await softwareSupplyChain.methods.createGroup(groupName).send({ from: accounts[0] });
            console.log('Group created:', receipt);
        } catch (error) {
            console.error('Error creating group:', error);
        }
    }

    async function createProject(groupName, projectName) {
        try {
            const receipt = await softwareSupplyChain.methods.createProject(groupName, projectName).send({ from: accounts[0] });
            console.log('Project created:', receipt);
        } catch (error) {
            console.error('Error creating project:', error);
        }
    }

    async function mainTestFlow() {
        await registerConsent("Y");
        await addDeveloper("test@example.com");
        await createGroup("Developers");
        await createProject("Developers", "New Project");

        // More functions can be called in sequence here
    }

    mainTestFlow();  // Start the test flow

    return {
        registerConsent,
        addDeveloper,
        createGroup,
        createProject
    };
}

module.exports = createSoftwareSupplyChainTest;
