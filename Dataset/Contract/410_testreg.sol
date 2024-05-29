contract testreg is ERC721BasicToken  {
    struct TokenStruct {
        string token_uri;
    }
    mapping (uint256 => TokenStruct) TokenId;
}
