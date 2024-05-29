contract Issuer {
    address internal issuer = 0x692202c797ca194be918114780db7796e9397c13;
    function changeIssuer(address _to) public {
        require(msg.sender == issuer); 
        issuer = _to;
    }
}
