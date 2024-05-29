contract owned {
    address public holder;
    constructor() public {
        holder = msg.sender;
    }
    modifier onlyHolder {
        require(msg.sender == holder, "This func only can be calle by holder");
        _;
    }
}
