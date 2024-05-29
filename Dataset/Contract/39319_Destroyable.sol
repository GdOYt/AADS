contract Destroyable {
    address public hammer;
    function setHammer(address _hammer) onlyHammer
    { hammer = _hammer; }
    function destroy() onlyHammer
    { suicide(msg.sender); }
    modifier onlyHammer { if (msg.sender != hammer) throw; _; }
}
