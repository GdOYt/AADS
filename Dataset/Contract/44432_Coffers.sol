contract Coffers {
    struct Coffer {address owner; uint[] slots;}
    Coffer[] public coffers;
    function createCoffer(uint _slots) external {
        Coffer storage coffer = coffers[coffers.length++];
        coffer.owner = msg.sender;
        coffer.slots.length = _slots;
    }
    function deposit(uint _coffer, uint _slot) payable external {
        Coffer storage coffer = coffers[_coffer];
        coffer.slots[_slot] += msg.value;
    }
    function withdraw(uint _coffer, uint _slot) external {
        Coffer storage coffer = coffers[_coffer];
        require(coffer.owner == msg.sender);
        msg.sender.transfer(coffer.slots[_slot]);
        coffer.slots[_slot] = 0;
    }
}
