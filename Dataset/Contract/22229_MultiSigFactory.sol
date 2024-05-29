contract MultiSigFactory {
    event Create(address indexed caller, address createdContract);
    function create(address[] owners, uint256 required) returns (address wallet){
        wallet = new MultiSigStub(owners, required); 
        Create(msg.sender, wallet);
    }
}
