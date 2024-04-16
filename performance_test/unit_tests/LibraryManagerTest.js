function testModule(web3, abi, contractAddress, account, sampleLibraryCID, project, version, dependencies) {
    const libraryManager = new web3.eth.Contract(abi, contractAddress);

    async function addLibrary() {
        try {
            const receipt = await libraryManager.methods.addLibrary(project, sampleLibraryCID, version, dependencies, 10).send({ from: account });
            console.log('Library added:', receipt);
        } catch (error) {
            console.error('Error adding library:', error);
        }
    }

    async function reportMalicious() {
        try {
            const receipt = await libraryManager.methods.reportLibraryMalicious(sampleLibraryCID, account).send({ from: account });
            console.log('Library reported as malicious:', receipt);
        } catch (error) {
            console.error('Error reporting library:', error);
        }
    }

    addLibrary();
    setTimeout(reportMalicious, 3000);  // Report the library as malicious after adding it

}

module.exports = testModule;
