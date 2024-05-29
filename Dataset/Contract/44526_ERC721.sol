contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
        || interfaceId == type(IERC721Metadata).interfaceId
        || super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenID) public view virtual override returns (address) {
        address owner = _owners[tokenID];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenID) public view virtual override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenID.toString()))
        : '';
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenID) public virtual override {
        address owner = ERC721.ownerOf(tokenID);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenID);
    }
    function getApproved(uint256 tokenID) public view virtual override returns (address) {
        require(_exists(tokenID), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenID];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenID) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenID), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenID);
    }
    function safeTransferFrom(address from, address to, uint256 tokenID) public virtual override {
        safeTransferFrom(from, to, tokenID, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenID, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenID), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenID, _data);
    }
    function _safeTransfer(address from, address to, uint256 tokenID, bytes memory _data) internal virtual {
        _transfer(from, to, tokenID);
        require(_checkOnERC721Received(from, to, tokenID, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenID) internal view virtual returns (bool) {
        return _owners[tokenID] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenID) internal view virtual returns (bool) {
        require(_exists(tokenID), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenID);
        return (spender == owner || getApproved(tokenID) == spender || ERC721.isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenID) internal virtual {
        _safeMint(to, tokenID, "");
    }
    function _safeMint(address to, uint256 tokenID, bytes memory _data) internal virtual {
        _mint(to, tokenID);
        require(_checkOnERC721Received(address(0), to, tokenID, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenID) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenID), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenID);
        _balances[to] += 1;
        _owners[tokenID] = to;
        emit Transfer(address(0), to, tokenID);
    }
    function _burn(uint256 tokenID) internal virtual {
        address owner = ERC721.ownerOf(tokenID);
        _beforeTokenTransfer(owner, address(0), tokenID);
        _approve(address(0), tokenID);
        _balances[owner] -= 1;
        delete _owners[tokenID];
        emit Transfer(owner, address(0), tokenID);
    }
    function _transfer(address from, address to, uint256 tokenID) internal virtual {
        require(ERC721.ownerOf(tokenID) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenID);
        _approve(address(0), tokenID);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenID] = to;
        emit Transfer(from, to, tokenID);
    }
    function _approve(address to, uint256 tokenID) internal virtual {
        _tokenApprovals[tokenID] = to;
        emit Approval(ERC721.ownerOf(tokenID), to, tokenID);
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenID, bytes memory _data)
    private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenID, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenID) internal virtual { }
}
