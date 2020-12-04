# Smart Contract Based Auctions

This branch stores the smart contract code that was used to simulate a VCG auction on Ethereum Blockchain. We ran a simulation of VCG auction on ethereum blockchain. We made a smart contract for the auction and deployed it on a private blockchain using **Ganache** and **Remix-Ethereum**. We found that while running the auction, all nodes can access the data stored inside the contract and as a result all the nodes on the network were able to see highest bid and highest bidder anytime during the auction.

## Instructions to test the contract

* Open the [Remix IDE](https://remix.ethereum.org/) and create a new *.*sol* file. For steps ahead, we will refer this file by *auction.sol*. 

* Copy and Paste the code present inside *VCG.sol* in *auction.sol* and compile the code. 

* Download [Ganache GUI](https://www.trufflesuite.com/ganache) on your machine. Ganache helps you to test the smart contract on a private ethereum blockchain.

* Open Ganache and choose the option of **Quickstart**. You will be provided with 10 dummy accounts for making transactions and testing your smart contract. 

* On the left sidebar in Remix IDE, choose the option to Deploy the Smart Contract. 

* Change the Environment to Web3 Provider and change the endpoint to **RPC Server address** provided by Ganache under the accounts tab.

* Click on Deploy, you will be asked to provide the *bidding time* (Duration of bidding) and *address of benificiary* (address of seller). You can choose any one amongst the 10 addresses as the benificiary.  

* After clicking on transact, the auction would be created and the smart contract would appear in the Deployed Contracts.

* You can check the variables and functions for a particular smart contract by clicking the down arrow near that smart contract in the *Deployed Contracts* section.

### To make a bid 

* Choose the account you want to make a bid with. 

* Choose the amount in ethers you want to bid.

* Click on bid button in the Deployed Contracts section.

* If the bid was successful, changes would get reflected in the **Ganache GUI** window.

**Note** - To change a bid, you need to withdraw the previous bid and make a new bid.

### Viewing the highest bid

Highest bid and bidder can respectively be seen by clicking on the respective buttons in the *Deployed Contracts* section.

### Ending the auction

* Change the account's address to the benificiary's account. 

* After the bidding time gets over, click on *auctionEnd* button in the Deployed Auction section.

* If successful, you can see on Ganache GUI that second highest bid will be deducted from the highest bidder's account and the benificiary will receive that much amount.

### Withdrawing the bids

* The losing bidders can withdraw their bids using the *withdraw* button in the Deployed Contracts section after the end of the auction.

* Any bidder can withdraw and make a new bid during bidding period by following the previous step.

