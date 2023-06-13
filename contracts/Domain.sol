// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Celo base contract library
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// Define the Domain contract
contract Domain is Initializable {

    // Define a struct to store domain information
    struct DomainInfo {
        string name; // The domain name
        address owner; // The domain owner
        uint256 price; // The domain price in wei
        bool forSale; // Whether the domain is for sale or not
    }

    // Define a mapping to store domains by name
    mapping (string => DomainInfo) public domains;

    // Define an event to emit when a domain is registered
    event DomainRegistered(string name, address owner, uint256 price);

    // Define an event to emit when a domain is transferred
    event DomainTransferred(string name, address from, address to, uint256 price);

    // Define an event to emit when a domain is listed for sale or unlisted
    event DomainListed(string name, address owner, uint256 price, bool forSale);

    // Define a modifier to check if the caller is the owner of a domain
    modifier onlyOwner(string memory _name) {
        require(domains[_name].owner == msg.sender, "Only owner can call this function");
        _;
    }

    // Initialize the contract with some default domains
    function initialize() public initializer {
        domains["celo.org"] = DomainInfo("celo.org", msg.sender, 1 ether, true);
        domains["clabs.co"] = DomainInfo("clabs.co", msg.sender, 2 ether, true);
        domains["ubeswap.org"] = DomainInfo("ubeswap.org", msg.sender, 3 ether, true);
        emit DomainRegistered("celo.org", msg.sender, 1 ether);
        emit DomainRegistered("clabs.co", msg.sender, 2 ether);
        emit DomainRegistered("ubeswap.org", msg.sender, 3 ether);
    }

    // Register a new domain name
    function registerDomain(string memory _name) public payable {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(domains[_name].owner == address(0), "Name already taken");
        require(msg.value > 0, "Price cannot be zero");
        domains[_name] = DomainInfo(_name, msg.sender, msg.value, false);
        emit DomainRegistered(_name, msg.sender, msg.value);
    }

    // Transfer a domain name to another address
    function transferDomain(string memory _name, address _to) public onlyOwner(_name) {
        require(_to != address(0), "Invalid address");
        require(_to != msg.sender, "Cannot transfer to self");
        domains[_name].owner = _to;
        emit DomainTransferred(_name, msg.sender, _to, domains[_name].price);
    }

    // List or unlist a domain name for sale
    function listDomain(string memory _name, uint256 _price, bool _forSale) public onlyOwner(_name) {
        require(_price > 0, "Price cannot be zero");
        domains[_name].price = _price;
        domains[_name].forSale = _forSale;
        emit DomainListed(_name, msg.sender, _price, _forSale);
    }

    // Buy a domain name from another address
    function buyDomain(string memory _name) public payable {
        require(domains[_name].owner != address(0), "Name does not exist");
        require(domains[_name].owner != msg.sender, "Cannot buy own domain");
        require(domains[_name].forSale, "Domain not for sale");
        require(msg.value >= domains[_name].price, "Insufficient funds");
        address previousOwner = domains[_name].owner;
        domains[_name].owner = msg.sender;
        domains[_name].forSale = false;
        payable(previousOwner).transfer(msg.value);
        emit DomainTransferred(_name, previousOwner, msg.sender, msg.value);
    }
}
