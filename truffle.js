require('babel-register');
require('babel-polyfill');
const Web3 = require("web3");
const web3 = new Web3();
const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = "border guilt acoustic trumpet visual tragic culture brush such shift face forward";
const infuraToken = 'sPUTgbA2Fmxskn8vpqAs';

module.exports = {
    networks: {
        ganache: { // ganache
            host: 'localhost',
            port: 7545,
            network_id: '*',
            gas: 4612388
        },
        truffle: { // truffle develop
            host: 'localhost',
            port: 9545,
            network_id: '*',
            gas: 4612388
        },
        rinkeby: {
            provider: function () {
                return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/" + infuraToken)
            },
            from: "",
            network_id: 4,
            gas: 7000000
        },
        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/" + infuraToken)
            },
            from: "",
            network_id: 4
        },
        live: { // testnet
            host: "localhost",
            port: 7545,
            from: "",
            network_id: 4,
            gas: 6000000
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    mocha: {
        useColors: true
    }
};
