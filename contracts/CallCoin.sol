pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title CallCoin
 */
contract CallCoin is StandardToken, Ownable, BurnableToken {
    string public constant name = "CallCoin";
    string public constant symbol = "CALL";
    uint8 public constant decimals = 18;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function CallCoin(uint256 _initialSupply) public {
        totalSupply_ = _initialSupply;
        balances[msg.sender] = _initialSupply;
        Transfer(0x0, msg.sender, _initialSupply);
    }
}
