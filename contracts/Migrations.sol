// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Celo base contract library
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// Define the Migrations contract
contract Migrations is Initializable {
  address public owner;
  uint public last_completed_migration;

  // Define a modifier to check if the caller is the owner
  modifier restricted() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }

  // Initialize the contract with the owner address
  function initialize() public initializer {
    owner = msg.sender;
  }

  // Set the last completed migration
  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  // Upgrade the contract address
  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
