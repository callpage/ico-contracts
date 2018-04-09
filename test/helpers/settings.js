

module.exports.settings = {
    getOpeningTime: function (network) {
        return network === 'live' ? this.openingTime + duration.seconds(120) : this.openingTime + duration.seconds(1);
    },

    openingTime: web3.eth.getBlock('latest').timestamp,

    closingTime: web3.eth.getBlock('latest').timestamp + duration.days(60),

    // 155M tokens
    initialSupply: new web3.BigNumber(155000000),

    // 2000 tokens per ETH
    baseRate: new web3.BigNumber(2000),

    goal: web3.toWei(5000),

    hardCap: web3.toWei(20000),

    // PrivateSale bonus, PreSale bonus, PublicSale week 1 bonus, PublicSale week 2 bonus, PublicSale week 3 bonus, Public Sale > week 4 bonus
    bonuses: [35, 30, 25, 10, 5],

    // PrivateSaleEndsTime, PreSaleEndsTime, PublicSaleWeek1EndsTime, PublicSaleWeek2EndsTime, PublicSaleWeek3EndsTime
    periods: [
        web3.eth.getBlock('latest').timestamp + duration.weeks(4),
        web3.eth.getBlock('latest').timestamp + duration.weeks(8),
        web3.eth.getBlock('latest').timestamp + duration.weeks(9),
        web3.eth.getBlock('latest').timestamp + duration.weeks(10),
        web3.eth.getBlock('latest').timestamp + duration.weeks(11),
    ],

    getOwnerWallet: function (accounts) {
        return accounts[0];
    },

    getFoundersWallet: function (accounts) {
        return accounts[1];
    },

    getAdvisorsWallet: function (accounts) {
        return accounts[2];
    },

    getReferralWallet: function (accounts) {
        return accounts[3];
    },

    getBountyWallet: function (accounts) {
        return accounts[4];
    }
};
