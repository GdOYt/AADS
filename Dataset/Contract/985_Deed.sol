contract Deed {
    address constant burn = 0xdead;
    address public registrar;
    address public owner;
    address public previousOwner;
    uint public creationDate;
    uint public value;
    bool active;
    event OwnerChanged(address newOwner);
    event DeedClosed();
    modifier onlyRegistrar {
        require(msg.sender == registrar);
        _;
    }
    modifier onlyActive {
        require(active);
        _;
    }
    function Deed(address _owner) public payable {
        owner = _owner;
        registrar = msg.sender;
        creationDate = now;
        active = true;
        value = msg.value;
    }
    function setOwner(address newOwner) public onlyRegistrar {
        require(newOwner != 0);
        previousOwner = owner;   
        owner = newOwner;
        OwnerChanged(newOwner);
    }
    function setRegistrar(address newRegistrar) public onlyRegistrar {
        registrar = newRegistrar;
    }
    function setBalance(uint newValue, bool throwOnFailure) public onlyRegistrar onlyActive {
        require(value >= newValue);
        value = newValue;
        require(owner.send(this.balance - newValue) || !throwOnFailure);
    }
    function closeDeed(uint refundRatio) public onlyRegistrar onlyActive {
        active = false;
        require(burn.send(((1000 - refundRatio) * this.balance)/1000));
        DeedClosed();
        destroyDeed();
    }
    function destroyDeed() public {
        require(!active);
        if (owner.send(this.balance)) {
            selfdestruct(burn);
        }
    }
}
