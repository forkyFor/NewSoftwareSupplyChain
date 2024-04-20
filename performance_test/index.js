const Web3 = require('web3');
const fs = require('fs');
const path = require('path');
const solc = require('solc');
require('dotenv').config({ path: '../.env' });

// Set up web3 provider
var web3 = new Web3(new Web3.providers.WebsocketProvider(process.env.BLOCKCHAIN_ADDRESS_WS));
const sampleAddress = '0x0242000F2df854b0242C82eEF58deB849b77dF28'; // Replace with actual Ethereum address
const contract_main = 'SoftwareSupplyChain'
const contracts = ['ConsentManager','DeveloperManager','GroupManager','LibraryManager','ProjectManager', 'DB']

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

// Compile the Solidity contract
function compileContract(contract) {

    const contractSol = contract + '.sol';
    const contractJSON = contract + '.json';
    

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
        let contractPath = path.resolve(__dirname, '../contracts', contractSol);
        let contractSource = fs.readFileSync(contractPath, 'utf8');
        input.sources[contractSol] = {
            content: contractSource,
        };
    
    }

    
    const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));
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

let sender = accounts[Math.floor(Math.random() * accounts.length)];

function compilatingContract(contract){
    
    let abi;
    if(contract !== "DB"){
        let compiledContract = compileContract(contract);
        abi = compiledContract.abi;
    }
    
    try {
        
        let testModule;
        testModule = require(`./unit_tests/${contract}Test`);
        switch(contract){
            case "DeveloperManager":{
                testModule(web3, abi, sampleAddress, sender);
                break;
            }            
            case "ProjectManager":{
                testModule(web3, abi, sampleAddress, "project_id", sender, "Developers");
                break;
            }
            case "GroupManager":{
                testModule(web3, abi, sampleAddress, sender, "Developers");
                break;
            }
            case "DB":{
                testModule(sender);
                break;
            }
            case "SoftwareSupplyChain":{
                testModule(web3, abi, sampleAddress, sender, "Y" , "test@example.com" , "Developers", "project_id" );
                break;
            }
            case "LibraryManager":{
                idCID = "QmTzF7NjPn5PriM7KCoF3T2k8xYPNspk9VNB8JY"
                dependencies = ["QmXkFfYTi9JFyU7VGiVR9vPb7LfGJS1KU5f3X", "QmPmCJpciVKqeP7V8K732B3scbF9iR8J4V8xjH"];
                testModule(web3, abi, sampleAddress, sender, idCID , "project_id" , "1.0.0", dependencies );
                break;
            }
            default:{
                testModule(web3, abi, sampleAddress);
            }
        }

    } catch (error) {
        console.error(`Error loading test module for ${contract}:`, error);
    }
}

compilatingContract(contract_main);

setTimeout(async () => {
    contracts.forEach(contract => {
        compilatingContract(contract);
    })
}, 5000);
