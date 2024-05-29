contract TakeBack is Ownable{
    address public tokenAdd;
    address public supervisor;
    uint256 public networkId;
    mapping (address => uint256) public userToNonce;
    event TakedBack(address indexed _user, uint indexed _nonce, uint256 _value);
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    constructor(address _token, address _supervisor, uint256 _networkId) public {
        tokenAdd = _token;
        supervisor = _supervisor;
        networkId = _networkId;
    }
    function takeBack(uint256 _nonce, uint256 _value, bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) public {
        address _user = msg.sender;
        require(userToNonce[_user] == _nonce);
        require(supervisor == verify(_hashmessage, _v, _r, _s));
        require(keccak256(abi.encodePacked(_user,_nonce,_value,networkId)) == _hashmessage);
        ERC20 token = ERC20(tokenAdd);
        token.transfer(_user, _value);
        userToNonce[_user]  += 1;
        emit TakedBack(_user, _nonce, _value);
    }
    function verify(bytes32 _hashmessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19EvolutionLand Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hashmessage));
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
    }
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }
    function changeSupervisor(address _newSupervisor) public onlyOwner {
        supervisor = _newSupervisor;
    }
}
