contract ICWToken is StandardToken {
    string public constant name = "Intelligent Car Washing Token";
    string public constant symbol = "ICWT";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 20000000000 * (10 ** uint256(decimals));
    address public contributorsAddress = 0x42cd691a49e8FF418528Fe906553B002846dE3cf;
    address public companyAddress = 0xf9C722e5c7c3313BBcD80e9A78e055391f75C732;
    address public marketAddress = 0xbd2F5D1975ccE83dfbf2B5743B1F8409CF211f90;
    address public icoAddress = 0xe26E3a77cA40b3e04C64E29f6c076Eec25a66E76;
    uint8 public constant CONTRIBUTORS_SHARE = 30;
    uint8 public constant COMPANY_SHARE = 20;
    uint8 public constant MARKET_SHARE = 30;
    uint8 public constant ICO_SHARE = 20;
    constructor() public {
        totalSupply = INITIAL_SUPPLY;
        uint256 valueContributorsAddress = INITIAL_SUPPLY.mul(CONTRIBUTORS_SHARE).div(100);
        balances[contributorsAddress] = valueContributorsAddress;
        emit Transfer(address(0), contributorsAddress, valueContributorsAddress);
        uint256 valueCompanyAddress = INITIAL_SUPPLY.mul(COMPANY_SHARE).div(100);
        balances[companyAddress] = valueCompanyAddress;
        emit Transfer(address(0), companyAddress, valueCompanyAddress);
        uint256 valueMarketAddress = INITIAL_SUPPLY.mul(MARKET_SHARE).div(100);
        balances[marketAddress] = valueMarketAddress;
        emit Transfer(address(0), marketAddress, valueMarketAddress);
        uint256 valueIcoAddress = INITIAL_SUPPLY.mul(ICO_SHARE).div(100);
        balances[icoAddress] = valueIcoAddress;
        emit Transfer(address(0), icoAddress, valueIcoAddress);
    }
}
