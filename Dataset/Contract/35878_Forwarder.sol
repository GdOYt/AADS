contract Forwarder is RegBase {
    bytes32 constant public VERSION = "Forwarder v0.3.0";
    address public forwardTo;
    event Forwarded(
        address indexed _from,
        address indexed _to,
        uint _value);
    function Forwarder(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        forwardTo = owner;
    }
    function ()
        public
        payable 
    {
        Forwarded(msg.sender, forwardTo, msg.value);
        require(forwardTo.call.value(msg.value)(msg.data));
    }
    function changeForwardTo(address _forwardTo)
        public
        returns (bool)
    {
        require(msg.sender == owner || msg.sender == forwardTo);
        forwardTo = _forwardTo;
        return true;
    }
}
