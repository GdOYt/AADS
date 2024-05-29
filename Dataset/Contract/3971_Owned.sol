contract Owned {
    address public owner = msg.sender;
    constructor(address _owner) public {
        if ( _owner == 0x00 ) {
            _owner = msg.sender;
        }
        owner = _owner;
    }
    function replaceOwner(address _owner) external returns(bool) {
        require( isOwner() );
        owner = _owner;
        return true;
    }
    function isOwner() internal view returns(bool) {
        return owner == msg.sender;
    }
    modifier forOwner {
        require( isOwner() );
        _;
    }
}
