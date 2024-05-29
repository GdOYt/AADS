contract ICOEngineInterface {
    function started() public view returns(bool);
    function ended() public view returns(bool);
    function startTime() public view returns(uint);
    function endTime() public view returns(uint);
    function totalTokens() public view returns(uint);
    function remainingTokens() public view returns(uint);
    function price() public view returns(uint);
}
