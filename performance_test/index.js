const Web3 = require('web3');
const fs = require('fs');
const path = require('path');
const solc = require('solc');
require('dotenv').config({ path: '../.env' });

// Set up web3 provider
var web3 = new Web3(new Web3.providers.WebsocketProvider(process.env.BLOCKCHAIN_ADDRESS_WS));
const sampleAddress = '...'; // Replace with actual Ethereum address
const contract_main = 'SoftwareSupplyChain'
const contracts = ['ConsentManager','DeveloperManager','GroupManager','LibraryManager','ProjectManager']


// Compile the Solidity contract
function compileContract(contract) {

    const contractSol = contract + '.sol';
    const contractJSON = contract + '.json';
    let contractPath = path.resolve(__dirname, '../contracts', contractSol);
    let contractSource = fs.readFileSync(contractPath, 'utf8');

    let input = {
        language: 'Solidity',
        sources: {},
        settings: {
            outputSelection: {
                '*': {
                    '*': ['*']
                }
            }
        }
    };

    
    if(contract == "SoftwareSupplyChain"){        
        contractPath = path.resolve(__dirname, '../contracts', contract_main + ".sol");
        contractSource = fs.readFileSync(contractPath, 'utf8');
        input.sources[contract_main + ".sol"] = {
            content: contractSource,
        };
    }else{

        input.sources[contractSol] = {
            content: contractSource,
        };
    
    }

    
    const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));
    console.log(output);
    fs.writeFileSync(path.resolve(__dirname, './build/' + contractJSON), JSON.stringify(output.contracts[contractSol][contract]));
    if (output.errors) {
        output.errors.forEach(err => {
            console.error(err.formattedMessage);
        });
    }
    
    const compiledContract = output.contracts[contractSol][contract];
    return compiledContract;
}

function findImports(importPath) {

    // Normalize the path to prevent errors in different OS environments
    const fullPath = path.resolve("../", importPath);

    try {
        if (fs.existsSync(fullPath)) {
            return { contents: fs.readFileSync(fullPath, 'utf8') };
        } else {
            return { error: 'File not found: ' + fullPath };
        }
    } catch (error) {
        return { error: error.message };
    }
}

function compilatingContract(contract){
    let compiledContract = compileContract(contract);
    let abi = compiledContract.abi;
    try {
        const testModule = require(`./unit_tests/${contract}Test`);
        testModule(web3, abi, sampleAddress);
    } catch (error) {
        console.error(`Error loading test module for ${contract}:`, error);
    }
}


contracts.forEach(contract => {
    compilatingContract(contract);
});

compilatingContract(contract_main);






