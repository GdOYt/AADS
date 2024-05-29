contract HOWTokenSafe is TokenSafe {
  constructor(address _token) 
    TokenSafe(_token)
    public
  {
    init(
      0,  
      1532779200  
    );
    add(
      0,  
      0xCD3367edbf18C379FA6FBD9D2C206DbB83A816AD,  
      53500000000000000000000000   
    );
  }
}
