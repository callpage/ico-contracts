const now = 1523750400; // 15 april
const CallCoinCrowdsale = artifacts.require('./CallCoinCrowdsale.sol');
const duration = {
    seconds: function (val) {
        return val
    },
    minutes: function (val) {
        return val * this.seconds(60)
    },
    hours: function (val) {
        return val * this.minutes(60)
    },
    days: function (val) {
        return val * this.hours(24)
    },
    weeks: function (val) {
        return val * this.days(7)
    },
    years: function (val) {
        return val * this.days(365)
    }
};
const settings = {
    getOpeningTime: function (network) {
        return network === 'live' ? this.openingTime + duration.seconds(120) : this.openingTime + duration.seconds(1);
    },

    openingTime: now,

    closingTime: now + duration.days(60),

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
        now + duration.weeks(4),
        now + duration.weeks(8),
        now + duration.weeks(9),
        now + duration.weeks(10),
        now + duration.weeks(11),
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

module.exports = function (deployer, network, accounts) {
    return deployer.deploy(
        CallCoinCrowdsale,
        settings.initialSupply,
        settings.getOpeningTime(),
        settings.closingTime,
        settings.baseRate,
        settings.hardCap,
        settings.goal,
        settings.bonuses,
        settings.periods,
        // wallets
        [
            settings.getOwnerWallet(accounts),
            settings.getFoundersWallet(accounts),
            settings.getAdvisorsWallet(accounts),
            settings.getReferralWallet(accounts),
            settings.getBountyWallet(accounts)
        ],
        {
            gas: 4012388
        }
    );
};
