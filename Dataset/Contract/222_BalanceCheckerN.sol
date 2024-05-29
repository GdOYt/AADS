contract BalanceCheckerN {
    address public admin;
    constructor() {
        admin = 0x96670A91E1A0dbAde97fCDC0ABdDEe769C21fc8e;
    }
    function() public payable {
        revert();
    }
    modifier isAdmin() {
        require(msg.sender == admin);
         _;
    }
    function destruct() public isAdmin {
        selfdestruct(admin);
    }
    function withdraw() public isAdmin {
        admin.transfer(address(this).balance);
    }
    function withdrawToken(address token, uint amount) public isAdmin {
        require(token != address(0x0));  
        require(Token(token).transfer(msg.sender, amount));
    }
   function tokenAllowance(address user, address spender, address token) public view returns (uint) {
        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) }  
        if(tokenCode > 0)
        {
            Token tok = Token(token);
            if(address(tok).call(bytes4(keccak256("allowance(address,address)")), user, spender)) {
                return tok.allowance(user, spender);
            } else {
                  return 0;  
            }
        } else {
            return 0;  
        }
   }
   function tokenBalance(address user, address token) public view returns (uint) {
        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) }  
        if(tokenCode > 0)
        {
            Token tok = Token(token);
            if(address(tok).call(bytes4(keccak256("balanceOf(address)")), user)) {
                return tok.balanceOf(user);
            } else {
                  return 0;  
            }
        } else {
            return 0;  
        }
   }
    function walletBalances(address user,  address[] tokens) public view returns (uint[]) {
        require(tokens.length > 0);
        uint[] memory balances = new uint[](tokens.length);
        for(uint i = 0; i< tokens.length; i++){
            if( tokens[i] != address(0x0) ) {  
                balances[i] = tokenBalance(user, tokens[i]);
            }
            else {
               balances[i] = user.balance;  
            }
        }
        return balances;
    }
    function walletAllowances(address user,  address spender, address[] tokens) public view returns (uint[]) {
        require(tokens.length > 0);
        uint[] memory allowances = new uint[](tokens.length);
        for(uint i = 0; i< tokens.length; i++){
            allowances[i] = tokenAllowance(user, spender, tokens[i]);
        }
        return allowances;
    }
    function allAllowancesForManyAccounts(
        address[] users,
        address spender,
        address[] tokens)
    public view returns (uint[]) {
        uint[] memory allowances = new uint[](tokens.length * users.length);
        for(uint user = 0; user < users.length; user++){
            for(uint token = 0; token < tokens.length; token++) {
                    allowances[(user * tokens.length) + token] = tokenAllowance(users[user], spender, tokens[token]);
          }
        }
        return allowances;
    }
    function allBalancesForManyAccounts(
        address[] users,
        address[] tokens)
    public view returns (uint[]) {
        uint[] memory balances = new uint[](tokens.length * users.length);
        for(uint user = 0; user < users.length; user++){
            for(uint token = 0; token < tokens.length; token++){
                if( tokens[token] != address(0x0) ) {  
                    balances[(user * tokens.length) + token] = tokenBalance(users[user], tokens[token]);
                } else {
                   balances[(user * tokens.length) + token] =  users[user].balance;
                }
            }
        }
        return balances;
    }
    function allWETHbalances(
        address wethAddress,
        address[] users
    ) public view returns (uint[]) {
        WETH_0x weth = WETH_0x(wethAddress);
        uint[] memory balances = new uint[](users.length);
        for(uint k = 0; k < users.length; k++){
            balances[k] = weth.balanceOf(users[k]);
        }
        return balances;
    }
}
