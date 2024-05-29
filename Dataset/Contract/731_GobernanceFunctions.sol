contract GobernanceFunctions is PortfolioFunctions{
    modifier IsOwner{
        require(owner == msg.sender, "not the owner");
        _;
    }
    function addBank(address _addressBank, uint256 _tokens) IsOwner public{
        require(banks[_addressBank].Owner==0);
        require(clients[_addressBank].Owner == 0);
        banks[_addressBank].Owner=_addressBank;
        banks[_addressBank].Tokens =  _tokens;
    }
    function addClient (address _addressClient, uint256 _category) IsOwner  public{
        require(banks[_addressClient].Owner!=_addressClient, "that addreess is a bank");
        require(clients[_addressClient].Owner!=_addressClient, "that client already exists");
        require (_category > 0);
        clients[_addressClient].Owner = _addressClient;
        clients[_addressClient].Category =  _category; 
        clients[_addressClient].Tokens =  0;
    }
    function addTokensToBank(address _bank, uint256 _tokens) IsOwner public{
        require(banks[_bank].Owner==_bank, "not a Bank");
        banks[_bank].Tokens = banks[_bank].Tokens.add(_tokens);
    }
    function changeClientCategory (address _client, uint256 _category) IsOwner public{
        require (clients[_client].Owner==_client, "not a client");
        clients[_client].Category = _category;
    }
}
