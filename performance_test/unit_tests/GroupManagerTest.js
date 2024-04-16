function testModule(web3, abi, contractAddress, adminAddress, sampleGroup ) {
    const groupManager = new web3.eth.Contract(abi, contractAddress);

    async function addGroup() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await groupManager.methods.addDeveloperGroup(sampleGroup, adminAddress).send({ from: accounts[0] });
            console.log('Group added:', receipt);
        } catch (error) {
            console.error('Error adding group:', error);
        }
    }

    async function requestAccess() {
        try {
            const receipt = await groupManager.methods.requestGroupAccess(sampleGroup, adminAddress).send({ from: adminAddress });
            console.log('Access requested for group:', receipt);
        } catch (error) {
            console.error('Error requesting access:', error);
        }
    }

    addGroup();
    setTimeout(requestAccess, 3000);  // Requests access after group is added

}

module.exports = testModule;
