contract TTCInterface is ERC20BaseInterface {
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool);
}
