contract Callee{
    uint data = 10;
    function increaseData(uint _val) public returns (uint){
        return data += _val;
    }
    function getData() public view returns (uint){
        return data;
    }
}
