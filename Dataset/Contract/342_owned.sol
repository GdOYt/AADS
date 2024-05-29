contract owned {
    address public holder;
    constructor() public {
        holder = msg.sender;
    }
    modifier onlyHolder {
        require(msg.sender == holder, "This function can only be called by holder");
        _;
    }
}
