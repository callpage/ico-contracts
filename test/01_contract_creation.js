'use strict'

const CallCoinCrowdsale = artifacts.require('./CallCoinCrowdsale.sol')
const advance = require('./helpers/advanceToBlock');
const time = require('./helpers/time');
const duration = require('./helpers/duration').duration;
const settings = require('./helpers/settings');

function ether(n) {
    return new web3.BigNumber(web3.toWei(n, 'ether'))
}

function wei(n) {
    return new web3.BigNumber(web3.fromWei(n, 'ether'))
}
