contract TeamVault is Ownable {
    using SafeMath for uint256;
    ERC20 public token_call;
    ERC20 public token_callg;
    event TeamWithdrawn(address indexed teamWallet, uint256 token_call, uint256 token_callg);
    constructor (ERC20 _token_call, ERC20 _token_callg) public {
        require(_token_call != address(0));
        require(_token_callg != address(0));
        token_call = _token_call;
        token_callg = _token_callg;
    }
    function () public payable {
    }
    function withdrawTeam(address teamWallet) public onlyOwner {
        require(teamWallet != address(0));
        uint call_balance = token_call.balanceOf(this);
        uint callg_balance = token_callg.balanceOf(this);
        token_call.transfer(teamWallet, call_balance);
        token_callg.transfer(teamWallet, callg_balance);
        emit TeamWithdrawn(teamWallet, call_balance, callg_balance);
    }
}
