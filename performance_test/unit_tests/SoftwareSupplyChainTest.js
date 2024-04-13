function testModule(web3, abi, contractAddress) {
    const softwareSupplyChain = new web3.eth.Contract(abi, contractAddress);


    // insert accounts test
    let accounts = [
        
        "0xC5441aD81ec6d67759F5A951b53F00aD94704A0f",
        "0x5498566a291A893C21E14648558c78078Bb02e30",
        "0x7c0a307c49DA24aD9A71953bA5143AF08076A691",
        "0x308f021E645fba4B4De04436f7a2A00113b86b43",
        "0x3002A2Fe766D94C5de5989e1791aAf3A6Cb39f60",
        "0xf76c9352929fCB7c76787d8AeaC729bfD0c51A0a",
        "0xB564c133FFE6F3207cbB8eFA4cF78a6aAa3b7EA2",
        "0xdeeC2de754b56A52890A36221FE34f014dD5f326",
        "0x3d73A221C5B76e0Da260df1eB84f0ac2eD95e44b"
    ]
    
    

    async function registerConsent(consent) {
        try {
            const receipt = await softwareSupplyChain.methods.registerConsent(consent).send({ from: accounts[Math.floor(Math.random() * accounts.length)]})
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

module.exports = testModule;
