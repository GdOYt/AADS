contract BurnableERC20 is ERC20 {
    function burn(uint256 amount) public returns (bool burned);
}
