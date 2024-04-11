function createConsentManager(web3, abi, contractAddress) {
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

    return {
        registerConsent,
        checkConsent
    };
}

module.exports = createConsentManager;
