contract ERC223ContractInterface {
    function erc223Fallback(address _from, uint256 _value, bytes _data){
        _from = _from;
        _value = _value;
        _data = _data;
        throw;
    }
}
