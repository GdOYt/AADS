contract InkProtocol is InkProtocolCore {
  address public constant __address0__ = 0xA13febeEde2B2924Ce8b27c1512874D3576fEC16;
  address public constant __address1__ = 0xc5bA7157b5B69B0fAe9332F30719Eecd79649486;
  address public constant __address2__ = 0x29a4b44364A8Bcb6e4d9dd60c222cCaca286ebf2;
  address public constant __address3__ = 0xc1DC1e5C3970E22201C5DAB0841abB2DD6499D3F;
  address public constant __address4__ = 0x0746d0b67BED258d94D06b15859df8dbd990eC3D;
  function InkProtocol() public {
    balances[__address0__] = 19625973697895500000000000;
    Transfer(address(0), __address0__, balanceOf(__address0__));
    TokenVesting vesting1 = new TokenVesting(__address1__, 1519776000, 0, 3 years, false);
    balances[vesting1] = 160000000000000000000000000;
    Transfer(address(0), vesting1, balanceOf(vesting1));
    TokenVesting vesting2 = new TokenVesting(__address2__, 1519776000, 0, 3 years, false);
    balances[vesting2] = 160000000000000000000000000;
    Transfer(address(0), vesting2, balanceOf(vesting2));
    balances[__address3__] = 30000000000000000000000000;
    Transfer(address(0), __address3__, balanceOf(__address3__));
    balances[__address4__] = 130374026302104500000000000;
    Transfer(address(0), __address4__, balanceOf(__address4__));
  }
}
