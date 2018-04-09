pragma solidity ^0.4.0;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol";
import './CallCoin.sol';

contract CallCoinCrowdsale is Crowdsale, TimedCrowdsale, FinalizableCrowdsale, PostDeliveryCrowdsale, CappedCrowdsale, RefundableCrowdsale {
    /*****
    * SaleState machine
    *  0 - PrivateSale: Contract is in the invite-only PartnerSale Period
    *  1 - PreSale:     Contract is in the PreSale Period
    *  2 - PublicSale:  Contract is in the PublicSale Period
    */
    enum SaleState {PrivateSale, PreSale, PublicSale}
    SaleState public state = SaleState.PrivateSale;

    // Token Distribution in percentages x10
    uint public constant TEAM_ALLOCATION = 100;                 // 10%
    uint public constant ADVISORS_ALLOCATION = 200;             // 20%
    uint public constant BOUNTY_ALLOCATION = 25;                // 2.5%
    uint public constant REFERRAL_ALLOCATION = 25;              // 2.5%
    uint public constant PRIVATE_SALE_ALLOCATION = 200;         // 20%
    uint public constant PRE_SALE_ALLOCATION = 200;             // 20%
    uint public constant PUBLIC_SALE_ALLOCATION = 250;          // 25%

    // Lockups
    uint public constant TEAM_LOCKUP = 24;
    uint public constant ADVISORS_LOCKUP = 12;

    address[] public wallets;

    // Token supply & rate
    uint256 public initialSupply;
    uint256 public initialRate;

    // Bonuses && periods
    uint256[] public bonuses;
    uint256[] public periods;

    // PrivateSale
    uint256 public weiRaisedPrivateSale = 0;
    uint256 public tokenPurchasedInPrivateSale = 0;
    uint256 public tokenLeftInPrivateSale;

    // PreSale
    uint256 public weiRaisedPreSale = 0;
    uint256 public tokenPurchasedInPreSale = 0;
    uint256 public tokenLeftInPreSale;

    // PublicSale
    uint256 public weiRaisedPublicSale = 0;
    uint256 public tokenPurchasedInPublicSale = 0;
    uint256 public tokenLeftInPublicSale;

    function CallCoinCrowdsale(
        uint256 _initialSupply,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _rate,
        uint256 _cap,
        uint256 _goal,
        uint256[] _bonuses,
        uint256[] _periods,
        address[] _wallets) public
    Crowdsale(_rate, _wallets[0], new CallCoin(_initialSupply))
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal)
    {
        // Goal needs to be less or equal than a cap
        require(_goal <= _cap);
        // Correct bonuses && periods array length
        require(_bonuses.length == 5 && _periods.length == 5);

        initialRate = _rate;
        initialSupply = _initialSupply;
        periods = _periods;
        bonuses = _bonuses;
        wallets = _wallets;

        // token sales allocation
        tokenLeftInPrivateSale = allocation(PRIVATE_SALE_ALLOCATION);
        tokenLeftInPreSale = allocation(PRE_SALE_ALLOCATION);
        tokenLeftInPublicSale = allocation(PUBLIC_SALE_ALLOCATION);
    }

    // ===============================================================================================
    // ===================================== Public functions ========================================

    /**
     * @param _beneficiary Address performing the token purchase
     * @dev Withdraw tokens only after crowdsale ends. Owner will call this when beneficiary passes the KYC
     */
    function withdrawTokens(address _beneficiary) public onlyOwner {
        require(hasClosed());
        uint256 amount = balances[_beneficiary];
        require(amount > 0);
        balances[_beneficiary] = 0;
        _deliverTokens(_beneficiary, amount);
    }

    // ===============================================================================================
    // ============================== Internal overriden functions ===================================

    /**
     * @dev Validation of an incoming purchase. Use require statemens to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        uint256 _tokens = _getTokenAmount(_weiAmount);

        if (isStatePrivateSale()) {
            require(now <= getPrivateSaleEndsTime());
            require(tokenPurchasedInPrivateSale + _tokens < tokenLeftInPrivateSale);
        } else if (isStatePreSale()) {
            require(now <= getPreSaleEndsTime());
            require(tokenPurchasedInPreSale + _tokens < tokenLeftInPreSale);
        } else if (isStatePublicSale()) {
            // no need to check timing, TimedCrowdsale already did it
            require(tokenPurchasedInPublicSale + _tokens < tokenLeftInPrivateSale);
        }

        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        uint256 _tokens = _getTokenAmount(_weiAmount);

        // measure wei raised during specific sale stage
        if (isStatePrivateSale()) {
            weiRaisedPrivateSale += _weiAmount;
            tokenPurchasedInPrivateSale += _tokens;
            tokenLeftInPrivateSale -= _tokens;
        } else if (isStatePreSale()) {
            weiRaisedPreSale += _weiAmount;
            tokenPurchasedInPreSale += _tokens;
            tokenLeftInPreSale -= _tokens;
        } else if (isStatePublicSale()) {
            weiRaisedPublicSale += _weiAmount;
            tokenPurchasedInPublicSale += _tokens;
            tokenLeftInPrivateSale -= _tokens;
        }

        // if PrivateSale ends or no token remains start the PreSale and move unsold tokens
        if ((isStatePrivateSale() && now > getPrivateSaleEndsTime()) ||
            (isStatePrivateSale() && tokenLeftInPrivateSale <= 0)) {
            setState(SaleState.PreSale);
            tokenLeftInPreSale += tokenLeftInPrivateSale;
            // if PreSale ends or no token remains start the PublicSale and move unsold tokens
        } else if ((isStatePreSale() && now > getPreSaleEndsTime()) ||
            (isStatePreSale() && tokenLeftInPreSale <= 0)) {
            setState(SaleState.PublicSale);
            tokenLeftInPublicSale += tokenLeftInPreSale;
        }

        super._updatePurchasingState(_beneficiary, _weiAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        if (isStatePrivateSale()) {
            wallet.transfer(msg.value);
        } else if (isStatePreSale()) {
            wallet.transfer(msg.value);
        } else {
            super._forwardFunds();
        }
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
        // distribute tokens to team and lock for 12 month
        distributeAndLock(wallets[1], allocation(TEAM_ALLOCATION), TEAM_LOCKUP);
        // distribute tokens to advisors and lock for 24 month
        distributeAndLock(wallets[2], allocation(ADVISORS_ALLOCATION), ADVISORS_LOCKUP);

        // distribute non-public tokens
        distribute(wallets[3], allocation(BOUNTY_ALLOCATION));
        distribute(wallets[4], allocation(REFERRAL_ALLOCATION));

        super.finalization();
    }

    /**
     * @dev Overrides parent method taking into account variable rate.
     * @param _weiAmount The value in wei to be converted into tokens
     * @return The number of tokens _weiAmount wei will buy at present time
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount).div(10 ** 18);
    }

    // ===============================================================================================
    // ===================================== Dev functions ===========================================

    /**
     * @dev
     * @param _recipient Address where to transfer tokens
     * @param _allocation How much tokens to transfer
     */
    function distribute(address _recipient, uint256 _allocation) private {
        token.transfer(_recipient, _allocation);
    }

    /**
     * @dev
     * @param _recipient Adress where to transfer tokens
     * @param _allocation How much tokens to transfer
     * @param _lockUpPeriod How much tokens to transfer
     * @return TokenTimeLock
     */
    function distributeAndLock(address _recipient, uint256 _allocation, uint _lockUpPeriod) private returns (TokenTimelock) {
        TokenTimelock _timeLock = new TokenTimelock(token, _recipient, _lockUpPeriod);
        distribute(_timeLock, _allocation);
        return _timeLock;
    }

    /**
     * @dev Returns the rate of tokens per wei at the present time.
     * Note that, as price _increases_ with time, the rate _decreases_.
     * @return The number of tokens a buyer gets per wei at a given time
     */
    function getCurrentRate() public view returns (uint256) {
        uint256 _bonus;

        if (state == SaleState.PrivateSale) {
            _bonus = bonuses[0];
        } else if (state == SaleState.PreSale) {
            _bonus = bonuses[1];
        } else if (state == SaleState.PublicSale) {

            if (now <= periods[2]) {
                _bonus = bonuses[2];
            } else if (now <= periods[3]) {
                _bonus = bonuses[3];
            } else if (now <= periods[4]) {
                _bonus = bonuses[4];
            } else {
                _bonus = 0;
            }

        }

        return initialRate + initialRate.mul(_bonus).div(100);
    }

    function getUnsoldTokensAmount() public view returns (uint256)
    {
        uint256 _totalTokensForSale = allocation(PRIVATE_SALE_ALLOCATION) + allocation(PRE_SALE_ALLOCATION) + allocation(PUBLIC_SALE_ALLOCATION);
        return _totalTokensForSale - (tokenPurchasedInPrivateSale + tokenPurchasedInPreSale + tokenPurchasedInPublicSale);
    }

    function allocation(uint _percentage) private view returns (uint256) {
        return initialSupply.mul(_percentage).div(10);
    }

    function getPrivateSaleEndsTime() private view returns (uint256) {
        return periods[0];
    }

    function getPreSaleEndsTime() private view returns (uint256) {
        return periods[1];
    }

    function getPublicSaleEndsTime() private view returns (uint256) {
        return closingTime;
    }

    function isStatePrivateSale() private view returns (bool) {
        return state == SaleState.PrivateSale;
    }

    function isStatePreSale() private view returns (bool) {
        return state == SaleState.PreSale;
    }

    function isStatePublicSale() private view returns (bool) {
        return state == SaleState.PublicSale;
    }

    // Change SalesStage. Available Options: PrivateSale, PreSale, PublicSale
    function setState(SaleState _state) private {
        state = SaleState(uint(_state));
    }

    // Change the current rate
    function setRate(uint256 _rate) private {
        rate = _rate;
    }
}
