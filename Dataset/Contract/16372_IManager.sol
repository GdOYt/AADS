contract IManager {
    event SetController(address controller);
    event ParameterUpdate(string param);
    function setController(address _controller) external;
}