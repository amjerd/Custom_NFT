# Kakke NFT Contract 🚀

**Kakke** is a custom-built ERC-721 NFT smart contract written in Solidity ^0.8.20. Unlike standard implementations, this contract is **fully built from scratch**—no OpenZeppelin ERC721 base was used. It supports minting, transferring, approvals, and burning with a focus on **security, gas efficiency, and flexibility**.

---

## Why this is unique

* ✅ **Custom ERC721 logic:** Built manually, giving full control over storage and events.
* ✅ **Owner-only minting and contract-controlled burn:** Ensures safety of token supply.
* ✅ **Gas optimization:** Uses `unchecked` blocks and custom errors instead of `require` strings.
* ✅ **Security features:** `ReentrancyGuard` for safe transfers, checks for zero addresses, and custom error handling.
* ✅ **Upgradeable metadata:** Base URI can be updated by the owner.

---

## Contract Overview

### Constructor

```solidity
constructor(string memory name_, string memory symbol_)
```

* Initializes the NFT with a **name** and **symbol**.

### Metadata

```solidity
function name() external view returns (string memory)
function symbol() external view returns (string memory)
function tokenURI(uint256 tokenId) external view returns (string memory)
function setBaseURI(string memory newURI) external
```

* Supports metadata management. Base URI is **owner-updatable**.

### Core ERC721 Functions

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
function balanceOf(address user) external view returns (uint256)
function approve(address to, uint256 tokenId) external
function getApprove(uint256 tokenId) external view returns (address)
function transferFrom(address from, address to, uint256 tokenId) external
```

* **Fully custom logic** for transfers, approvals, and ownership tracking.
* Approvals and transfers follow ERC721 standards but implemented manually.

### Custom Functions

```solidity
function mint() external
function burn(uint256 tokenId) external
function ContractBurn(uint256 tokenId) external
```

* `mint()` → Owner can mint new NFTs.
* `burn()` → Token owners can burn their NFT.
* `ContractBurn()` → Owner can burn NFTs held by the contract itself.

### Events

```solidity
event transfer(address indexed from, address indexed to, uint256 indexed tokenId)
event Approval(address indexed from, address indexed to, uint256 indexed tokenId)
```
