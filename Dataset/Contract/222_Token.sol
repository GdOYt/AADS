contract Token {
    function balanceOf(address tokenOwner) public view returns (uint  );
    function transfer(address toAddress, uint tokens) public returns (bool  );
    function allowance(address _owner, address _spender) constant returns (uint  );
}
