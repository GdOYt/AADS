contract BouleToken is MintableToken {
    string public name = "Boule Token";
    string public symbol = "BOU";
    uint public decimals = 18;
    function () public payable {
        throw;
    }
}
