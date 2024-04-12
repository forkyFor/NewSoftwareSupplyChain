function createProjectManagerTest(web3, abi, contractAddress, sampleProject, adminAddress, group) {
    const projectManager = new web3.eth.Contract(abi, contractAddress);

    async function addProject() {
        const accounts = await web3.eth.getAccounts();
        try {
            const receipt = await projectManager.methods.addProject(sampleProject, adminAddress, "", group).send({ from: adminAddress });
            console.log('Project added:', receipt);
        } catch (error) {
            console.error('Error adding project:', error);
        }
    }

    addProject();

}

module.exports = createProjectManagerTest;
