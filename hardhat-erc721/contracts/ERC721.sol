// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping (address => uint256) internal _balances;

    mapping (uint256 => address) internal _owners;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    mapping (uint256 => address) private _tokenApprovals;

    // Returns the bumber of NFTs assigned to an owner
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "address is zero");
        return _balances[owner];
    }
    
    // Finds the owner of an NFT
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token id does not exists");
        return owner;
    }

    // Enables or disables an operator to manage all of msg.senders assets.
    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // Checking if an address is an operator for another address
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // Updates an approved address for an NFTs
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender != owner || isApprovedForAll(owner, msg.sender), "Msg.sender is not the owner or an approved operator");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // Get the approved address for a single NFT
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token ID does not exists");
        return _tokenApprovals[tokenId];
    }

    // Transfer ownership of an NFT
    function transferFrom(address from, address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(
            msg.sender == owner ||
            getApproved(tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender),
            "Msg.sender is not owner or approved for transfer"
        );
        require(owner == from, "From address is not the owner");
        require(to != address(0), "To is zero address");
        require(_owners[tokenId] != address(0), "Token ID does nit exists");
        approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

    }

    // Standart transferFrom
    // Checks if onERC721Received is implemented WHEN sending to smart contracts
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(), "Received not implemented");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function _checkOnERC721Received() private pure returns (bool) {
        return true;
    }

    // EIP165: Query if a contract implements another interface
    function supportsInterface(uint256 interfaceId) public pure virtual returns (bool) {
        return interfaceId == 0x80ac58cd;
    }
    
}