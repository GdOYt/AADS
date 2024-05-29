contract TokenControllerI {
    function transferAllowed(address _from, address _to)
        external
        view 
        returns (bool);
}
