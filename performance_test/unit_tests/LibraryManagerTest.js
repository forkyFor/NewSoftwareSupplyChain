function createLibraryManagerTest(web3, abi, contractAddress, sampleLibraryCID, project, version, dependencies) {
    const libraryManager = new web3.eth.Contract(abi, contractAddress);

    async function addLibrary() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await libraryManager.methods.addLibrary(project, sampleLibraryCID, version, dependencies, 10).send({ from: accounts[0] });
            console.log('Library added:', receipt);
        } catch (error) {
            console.error('Error adding library:', error);
        }
    }

    async function reportMalicious() {
        try {
            const receipt = await libraryManager.methods.reportLibraryMalicious(sampleLibraryCID, accounts[0]).send({ from: accounts[0] });
            console.log('Library reported as malicious:', receipt);
        } catch (error) {
            console.error('Error reporting library:', error);
        }
    }

    addLibrary();
    setTimeout(reportMalicious, 3000);  // Report the library as malicious after adding it

}

module.exports = createLibraryManagerTest;
