function testModule(web3, abi, sampleAddress) {
    
    const contractAddress = process.env.consent_manager_address;
    const consentManager = new web3.eth.Contract(abi, contractAddress);

    async function registerConsent(address, consent) {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await consentManager.methods.registerConsent(address, consent).send({ from: accounts[0] });
            console.log('Transaction receipt:', receipt);
        } catch (error) {
            console.error('Error registering consent:', error);
        }
    }

    async function checkConsent(address) {
        try {
            const isConsented = await consentManager.methods.getConsent(address).call();
            console.log(`Consent status for ${address}: ${isConsented}`);
        } catch (error) {
            console.error('Error checking consent:', error);
        }
    }
    
    registerConsent(sampleAddress, 'Y'); // Registering consent

    setTimeout(() => {
        checkConsent(sampleAddress); // Checking consent
      }, 3000);
}

module.exports = testModule;
