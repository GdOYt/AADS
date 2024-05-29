contract Owned {
    address public contractOwner;
    function Owned() {
        contractOwner = msg.sender;
    }
    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }
}
