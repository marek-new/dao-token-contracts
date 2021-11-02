pragma solidity ^0.8.3;
import "@openzeppelin/contracts@4.3.2/token/ERC20/ERC20.sol";

/**
@title TimelockToken contract - allows a token unlock over time
Based on 
https://github.com/gnosis/disbursement-contracts/blob/master/contracts/Disbursement.sol
 +
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
**/

contract TimeLockToken is ERC20 {

    /*
     *  Storage
     */
    
    uint public disbursementPeriod;
    uint public startDate;
    uint public withdrawnTokens;

    /*
     *  Public functions
     */

     //TURN THIS INTO locking function
    /// @dev Constructor function sets the wallet address, which is allowed to withdraw all tokens anytime
    /// @param _receiver Receiver of vested tokens
    /// @param _wallet Gnosis multisig wallet address
    /// @param _disbursementPeriod Vesting period in seconds
    /// @param _startDate Start date of disbursement period (cliff)
    /// @param _token ERC20 token used for the vesting
    constructor(address _receiver, address _wallet, uint _disbursementPeriod, uint _startDate, Token _token)
        public
    {
        if (_receiver == address(0) || _wallet == address(0) || _disbursementPeriod == 0 || address(_token) == address(0))
            revert("Arguments are null");
        receiver = _receiver;
        wallet = _wallet;
        disbursementPeriod = _disbursementPeriod;
        startDate = _startDate;
        token = _token;
        if (startDate == 0){
          startDate = now;
        }
    }

//TURN THIS INTO PRE-TRANSFER HOOK
    /// @dev Transfers tokens to a given address
    /// @param _to Address of token receiver
    /// @param _value Number of tokens to transfer
    function withdraw(address _to, uint256 _value)
        public
        isReceiver
    {
        uint maxTokens = calcMaxWithdraw();
        if (_value > maxTokens){
          revert("Withdraw amount exceeds allowed tokens");
        }
        withdrawnTokens += _value;
        token.transfer(_to, _value);
    }

   
//CALCULATE THE NUMBER OF TRANSFERRABLE TOKENS
    /// @dev Calculates the maximum amount of vested tokens
    /// @return Number of vested tokens to withdraw
    function calcMaxWithdraw()
        public
        view
        returns (uint)
    {
        uint maxTokens = (token.balanceOf(address(this)) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
        if (withdrawnTokens >= maxTokens || startDate > now){
          return 0;
        }
        return maxTokens - withdrawnTokens;
    }
}