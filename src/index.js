// index.js

// Initialize web3
let web3;
if (window.ethereum) {
  web3 = new Web3(window.ethereum);
  window.ethereum.enable();
} else {
  alert("Please install MetaMask to use this dapp.");
}

// Initialize contract
const contract = new web3.eth.Contract(Domain.abi, contractAddress);

// Initialize variables
let account; // current user account
let domains = {}; // cache of domain info

// Get HTML elements
const status = document.getElementById("status");
const content = document.getElementById("content");
const accountSpan = document.getElementById("account");
const contractSpan = document.getElementById("contract");
const registerForm = document.getElementById("register-form");
const transferForm = document.getElementById("transfer-form");
const listForm = document.getElementById("list-form");
const buyForm = document.getElementById("buy-form");

// Handle register form submission
registerForm.addEventListener("submit", async (event) => {
  event.preventDefault(); // prevent page refresh
  const name = event.target.elements.name.value; // get domain name
  const price = event.target.elements.price.value; // get domain price
  status.textContent = "Registering domain..."; // update status
  try {
    // call registerDomain function from the contract
    await contract.methods.registerDomain(name).send({ from: account, value: price });
    status.textContent = "Domain registered successfully."; // update status
  } catch (error) {
    status.textContent = error.message; // update status
  }
});

// Handle transfer form submission
transferForm.addEventListener("submit", async (event) => {
  event.preventDefault(); // prevent page refresh
  const name = event.target.elements.name.value; // get domain name
  const to = event.target.elements.to.value; // get recipient address
  status.textContent = "Transferring domain..."; // update status
  try {
    // call transferDomain function from the contract
    await contract.methods.transferDomain(name, to).send({ from: account });
    status.textContent = "Domain transferred successfully."; // update status
  } catch (error) {
    status.textContent = error.message; // update status
  }
});

// Handle list form submission
listForm.addEventListener("submit", async (event) => {
  event.preventDefault(); // prevent page refresh
  const name = event.target.elements.name.value; // get domain name
  const price = event.target.elements.price.value; // get domain price
  const forSale = event.target.elements.forSale.value === "true"; // get for sale flag
  status.textContent = "Listing domain..."; // update status
  try {
    // call listDomain function from the contract
    await contract.methods.listDomain(name, price, forSale).send({ from: account });
    status.textContent = "Domain listed successfully."; // update status
  } catch (error) {
    status.textContent = error.message; // update status
  }
});

// Handle buy form submission
buyForm.addEventListener("submit", async (event) => {
  event.preventDefault(); // prevent page refresh
  const name = event.target.elements.name.value; // get domain name
  status.textContent = "Buying domain..."; // update status
  try {
    // get domain info from the contract or cache
    let domain = domains[name];
    if (!domain) {
      domain = await contract.methods.domains(name).call();
      domains[name] = domain; // update cache
    }
    // check if domain is for sale and price is valid
    if (domain.forSale && domain.price > 0) {
      // call buyDomain function from the contract
      await contract.methods.buyDomain(name).send({ from: account, value: domain.price });
      status.textContent = "Domain bought successfully."; // update status
    } else {
      status.textContent = "Domain is not for sale or has invalid price."; // update status
    }
  } catch (error) {
    status.textContent = error.message; // update status
  }
});

// Load user account and contract address
async function load() {
  // get user account from MetaMask
  const accounts = await web3.eth.getAccounts();
  account = accounts[0];
  accountSpan.textContent = account; // display user account

  contractSpan.textContent = contractAddress; // display contract address

  content.style.display = "block"; // show content div
  status.textContent = ""; // clear status

}

// Call load function when the page loads
window.addEventListener("load", load);

