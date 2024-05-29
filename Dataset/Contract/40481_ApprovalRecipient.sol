contract ApprovalRecipient {
    function receiveApproval(address _from, uint256 _amount,
                             address _tokenContract, bytes _extraData);
}
