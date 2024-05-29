contract WyvernDAOProxy is DelegateProxy {
    function WyvernDAOProxy ()
        public
    {
        owner = msg.sender;
    }
}
