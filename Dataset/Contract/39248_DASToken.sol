contract DASToken is ERC23Token {
    mapping (address => bool) blockedAccounts;
    address public secretaryGeneral;
    function DASToken(
            string _name,
            string _symbol,
            uint8 _decimals,
            uint256 _totalSupply,
            address _initialTokensHolder) {
        secretaryGeneral = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[_initialTokensHolder] = _totalSupply;
    }
    modifier onlySecretaryGeneral {
        if (msg.sender != secretaryGeneral) throw;
        _;
    }
    function blockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = true;
    }
    function unblockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = false;
    }
    function isAccountBlocked(address _account) returns (bool){
        return blockedAccounts[_account];
    }
    function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        return ERC23Token.transfer(_to, _value, _data);
    }
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        bytes memory empty;
        return ERC23Token.transfer(_to, _value, empty);
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (blockedAccounts[_from]) {
            throw;
        }
        return ERC23Token.transferFrom(_from, _to, _value);
    }
}
