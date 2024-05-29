contract HeadOrTail {
    bool public chosen;  
    bool lastChoiceHead;  
    address public lastParty;  
    function choose(bool _chooseHead) payable {
        require(!chosen);
        require(msg.value == 1 ether);
        chosen=true;
        lastChoiceHead=_chooseHead;
        lastParty=msg.sender;
    }
    function guess(bool _guessHead) payable {
        require(chosen);
        require(msg.value == 1 ether);
        if (_guessHead == lastChoiceHead)
            msg.sender.transfer(2 ether);
        else
            lastParty.transfer(2 ether);
        chosen=false;
    }
}
