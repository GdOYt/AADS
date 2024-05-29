contract TstTokenTimelock is Ownable, TokenTimelock {
  constructor(
    ERC20Basic _token,
    address _beneficiary,
    uint256 _releaseTime
  )
    public
    TokenTimelock(_token, _beneficiary, _releaseTime)
  {}
    function() public payable {
    }
    function withdrawEth(uint256 _value) public onlyOwner {
        owner.transfer(_value);
    }
    function transferAnyERC20Token(address _token_address, uint _amount) public onlyOwner returns (bool success) {
        require(_token_address != address(token));
        return ERC20Basic(_token_address).transfer(owner, _amount);
    }
}
