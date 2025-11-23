// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

interface IERC721 is IERC165 {
    event transfer(address indexed from,address indexed to,uint256 indexed tokenId);
    event Approval(address indexed from ,address indexed to,uint256 indexed tokenId);

    function ownerOf(uint256 tokenId)external view returns (address owner);
    function balanceOf(address owner) external view returns(uint256 tokenId);
    function approve(address to,uint256 tokenId)external;
    function getApprove(uint256 tokenId) external view returns(address operator);
    function transferFrom(address from,address to,uint256 tokenId) external ;

}
interface IERC721Metadata is IERC721 {
    function name()external view returns(string memory);
    function symbol()external view returns (string memory);
    function tokenURI(uint256 tokenId)external view returns (string memory);

    
}

contract kakke is IERC721Metadata,Ownable(msg.sender),ReentrancyGuard{
    //state variable and making them private for gas efficient
    string private _name;
    string private _symbol;
    string private _baseURI = "";
    uint256 private nextToken;

    constructor(string memory name_,string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }

    //mapping to store address of owners(id for each address),
    //approval(id for each address) 
    // balances(for each address)
     mapping (uint256 => address) private _owners;
     mapping (uint256 => address)private _tokenApproval;
     mapping (address => uint256) private _balancesOf;

     //custom errors
     error TokenDoesNotExist(uint256 tokenId);
     error NotOwner(address caller, uint256 tokenId);
     error CannotApproveSelf(uint256 tokenId);
     error NotApprovedOrOwner(address caller, uint256 tokenId);
     error ZeroAddressNotAllowed();
     error NotInOwnerCustody(uint256 tokenId);

     
      function supportsInterface(bytes4 interfaceId) external pure override returns(bool){
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC721).interfaceId 
        || interfaceId == type(IERC721Metadata).interfaceId;
      }
        function name()external view override  returns(string memory){
            return _name;
        }
      function symbol()external view override returns (string memory){
        return _symbol;
      }

      //token URI without helper
     function tokenURI(uint256 tokenId)external view override  returns (string memory){
        address owner = _owners[tokenId];
       if (owner == address(0)) revert TokenDoesNotExist(tokenId);
        return _baseURI;
     }
     function setBaseURI(string memory newURI) external onlyOwner {
     _baseURI = newURI;
}

     //viewing nft for each owner,making sure is not address(0)
      function ownerOf(uint256 tokenId)external view override  returns (address){
       address owner = _owners[tokenId];
       if (owner == address(0)) revert TokenDoesNotExist(tokenId);

        return owner;

      }
      //checking total number of nft for each user
    function balanceOf(address user) external view override  returns(uint256){
       if(user == address(0)) revert ZeroAddressNotAllowed();
        return _balancesOf[user];
   

    }
    //approving someone to spend your nft,and making sure only owner can approve
    //and give permission to spender to spend nft
    function approve(address to, uint256 tokenId) external override {
    address owner = _owners[tokenId];

    if (to == address(0)) revert ZeroAddressNotAllowed();
    if (owner == address(0)) revert TokenDoesNotExist(tokenId);
    if (owner != msg.sender) revert NotOwner(msg.sender, tokenId);
    if (to == owner) revert CannotApproveSelf(tokenId);


    _tokenApproval[tokenId] = to;

    emit Approval(owner, to, tokenId);


    }
    function getApprove(uint256 tokenId) external view override returns(address){
        return _tokenApproval[tokenId];

    }
    //transfering token to someone(no zero address,only owner of nft can send 
    //or making sure the sender is approved to send that specific nf
    function transferFrom(address from,address to,uint256 tokenId) external override nonReentrant{
        if (to == address(0)) revert ZeroAddressNotAllowed();

        address tokenOwner = _owners[tokenId];
        if (tokenOwner != from) revert NotOwner(msg.sender, tokenId);
        if (msg.sender != from && msg.sender != _tokenApproval[tokenId]) revert NotApprovedOrOwner(msg.sender, tokenId);


        //deducting balance of sender,increase balance of reciever,assure that nft belong to reciever
        //and making sure the approval of the nft revert
       
        unchecked {            //allowing underflow/overflow is safe for this
      _balancesOf[from] -= 1;
       _balancesOf[to] += 1;
       }

        _owners[tokenId] = to;
        _tokenApproval[tokenId] = address(0);
        
        emit transfer(from, to, tokenId);
    }
    //contract owner can mint,while the increase the total nft and saying this nft belongs to owner
    //and increase the balance of owner
    function mint()external  onlyOwner{
        uint256 tokenId = nextToken;
        unchecked { nextToken++; }

        _owners[tokenId] = msg.sender;
        _balancesOf[msg.sender] += 1;

        emit transfer(address(0),msg.sender, tokenId);

    }
    // chekc if the owner(user) is the one who wants to burn
    //reduce balance clear approval,delete ownership
   function burn(uint256 tokenId) external {

    address owner = _owners[tokenId];
    if (owner == address(0)) revert TokenDoesNotExist(tokenId);
    if (owner != msg.sender) revert NotOwner(msg.sender, tokenId);

    unchecked { _balancesOf[owner] -= 1; }


    _tokenApproval[tokenId] = address(0);

    delete _owners[tokenId];

    emit transfer(owner, address(0), tokenId);
}


function ContractBurn(uint256 tokenId) external onlyOwner{
    if (_owners[tokenId] != address(this)) revert NotInOwnerCustody(tokenId);

    delete _owners[tokenId];
}
}
