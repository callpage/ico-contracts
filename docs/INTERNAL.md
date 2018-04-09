### Useful commands

#### Deploy
truffle compile && truffle migrate --network=truffle --reset

#### Debug
truffle debug --network=truffle

##### Ganache cli
ganache-cli

##### solidity-flattener
solidity_flattener contracts/CallCoinCrowdsale.sol --solc-paths=zeppelin-solidity=$(pwd)/node_modules/zeppelin-solidity --output build/CallCoinCrowdsaleFlattened.sol

#### Web3JS helper commands
// Send test transaction
web3.eth.sendTransaction({ from: web3.eth.accounts[5], value: web3.toWei(0.1, "ether"), to: CallCoinCrowdsale.address, gas: 200000})

// check ETH balance
web3.eth.getBalance(web3.eth.accounts[5])
web3.eth.getBalance(web3.eth.accounts[0])

// withdraw tokens
crowdsale.withdrawTokens(web3.eth.accounts[5]);

// check tokens balance
crowdsale

// get balance of contract
web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]).toString())

// instance CallCoinCrowdsale
CallCoinCrowdsale.deployed().then(inst => {crowdsale = inst})

// instance CallCoin
crowdsale.token().then(inst => { address = inst })
CallCoin.at(address)

// Debug Log events
CallCoinCrowdsale.deployed().then(inst => {crowdsale = inst})
var events = crowdsale.allEvents()
events.watch(function(error, event){ if (!error && event.args.timestamp) console.log(event.args);});
