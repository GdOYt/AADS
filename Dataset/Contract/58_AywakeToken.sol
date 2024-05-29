contract AywakeToken is MiniMeToken {
     function AywakeToken (address _controller, address _tokenFactory)
        MiniMeToken(
            _tokenFactory,
            0x0,                         
            0,                           
            "AywakeToken",               
            18,                          
            "AWK",                       
            true                         
            )
    {
        changeController(_controller);
    }
}
