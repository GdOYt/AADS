contract Recipient {
    event ReceivedEther(address indexed sender,
                        uint256 indexed amount);
    event ReceivedTokens(address indexed from,
                         uint256 indexed value,
                         address indexed token,
                         bytes extraData);
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData) {
        if (!_token.transferFrom(_from, this, _value)) throw;
        ReceivedTokens(_from, _value, _token, _extraData);
    }
    function () payable
    { ReceivedEther(msg.sender, msg.value); }
}
