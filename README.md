# Start the program
### Prerequisites
1. python 3 https://www.python.org/downloads/
2. Git https://git-scm.com/
3. Ganache https://trufflesuite.com/ganache/
4. Node.js https://nodejs.org/en 
5. **npm-remote-ls**: This can be installed using npm. After installing Node.js, run `npm install -g npm-remote-ls` to install.
6. **Web3.storage Account**: Create an account at [Web3.storage](https://web3.storage) to obtain an IPFS token.
7. **Solidity Compiler (solc-js)**: Install the Solidity compiler for JavaScript (`solc-js`) to compile Solidity smart contracts. Run the following command:
    ```bash
    npm install -g solc
    ```

### Start
First, create a workspace on Ganache.

Clone the repository:
```bash
git clone https://github.com/forkyFor/NewSoftwareSupplyChain.git
```
Enter in the folder:
```bash
cd NewSoftwareSupplyChain
```
Install the requirements:
```bash
pip install -r requirements.txt
```
Execute deploy.py:
```bash
python deploy.py


```
Install Node.js Dependencies
Navigate to the Node.js directory of the project:
```bash
cd NewSoftwareSupplyChain/middleware


```
Install the dependencies with npm:
```bash
npm install

```
To start the Node.js server, ensure you're in the Node.js project directory and run:
```bash
npm start

```
The script will ask for the wallett address and the private key. Both these information can be found in one of the wallet created on Ganache. Also, the blockchain address is on Ganache. Insted, the IPFS token can be created on https://web3.storage.

Execute call_contract.py:
```bash
python call_contract.py
```
