contract DTXToken is MiniMeToken {
  function DTXToken(address _tokenFactory) public MiniMeToken (
    _tokenFactory,
    0x0,                     
    0,                       
    "DaTa eXchange Token",  
    18,                      
    "DTX",                  
    true                    
    )
  {}
}
