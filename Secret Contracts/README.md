# Secret network based Sealed bid VCG Auction

This is the step by step guide to run a VCG Auction implemented by us using Secret Network, for the CS711A course project.

The following instructions assume that you have secretcli, jq and the rust programming language installed.

To install secretcli:

1. Get the latest release of `secretcli` for your OS: https://github.com/enigmampc/SecretNetwork/releases/latest.

2. Install:

   - Mac/Windows: Rename it from `secretcli-${VERSION}-${OS}` to `secretcli` or `secretcli.exe` and put it in your path.
   - Ubuntu/Debian: `sudo dpkg -i secret*.deb`
   
3. Make it a directly executable binary:

   - `sudo mv /path/to/secretcli /usr/local/bin`

After these steps, follow the instructions to setup secretcli and rust given [here](https://blog.scrt.network/how-to-build-secret-apps/).

Install jq using `sudo apt-get install jq`

Also, ensure that you have SCRT tokens in the SCRT address you generate using secretcli. You can get tokens from [this SCRT faucet](https://faucet.secrettestnet.io/).

## Running On Holodeck-2 Testnet

If you wish to make changes to the auction code, edit the contract.rs file in the src folder, and set it up on the blockchain, following the steps [here](https://blog.scrt.network/how-to-build-secret-apps/) to create your own secret contract. You will need to store the Code ID of this contract to begin the auction.

### 1. Create Bid and Sell Tokens

The first step to deploy the auction is to create the sell and the bid tokens. The sell tokens will be offered by the seller, while the bidders will pay the bid tokens. Ideally, the seller will give the bid tokens to the buyers after taking some security deposit from them. Currently, it is necessary to create different bid and sell tokens.

You can create a new token with the following command:

```sh
secretcli tx compute instantiate 1 '{"name": "*token_name*","admin": "*address_with_admin_privileges*", "symbol": "*token_symbol*", "decimals": *decimal_places*, "initial_balances": [{"address": "*address1*", "amount": "*amount_for_address1*"}], "prng_seed": "*any_base64_encoded_string*","config": {"public_total_supply": *true_or_false*}}' --from *your_key_alias_or_addr* --label *name_for_the_contract* -y
```
Example usage:
```sh
secretcli tx compute instantiate 1 '{"name": "bidc", "symbol": "BIDC", "decimals": 3,"prng_seed":"cGV0ZQo=", "initial_balances": [{"address":"secret1kz35cdmsqahn7t39xdcxmat735a7c268jq3drd" , "amount": "1000"}, {"address":"secret1kwc62xtjpnu7cum9rrsdf4lyh8c5kxp76ngkeg" , "amount": "1000"}]}' --label bidc --from atharv -y
```
Ensure that the symbol is of the form [A-Z]{4,6}

Here, 1 is the code ID of the default token protocol currently used in the secret network

You may include as many address/amount pairs as you like in the initial_balances field.

It is not necessary to fill in the admin field (automatically is assigned to the creator of the token protocol), and the config field.

After running these commands, you will receive the transaction hash, using which you can get the contract address using:
```sh
secretcli q tx *txHash*
```
And looking at the value corresponding to the contract_address field.

### 2. Creating a new auction

> **_Note_**: A bash script (named `auction.sh`) has been provided to run the steps 2-8.
> The script is expecting the auction contract to have code ID 49, which is the code ID of our VCG secret contract, but you can change that on the first line if you deploy a new version of the contract.  

You can create a new auction with
```sh
secretcli tx compute instantiate 49 '{"sell_contract": {"code_hash": "*sale_tokens_code_hash*", "address": "*sale_tokens_contract_address*"}, "bid_contract": {"code_hash": "*bid_tokens_code_hash*", "address": "*bid_tokens_contract_address*"}, "sell_amount": "*amount_being_sold_in_smallest_denomination_of_sale_token*", "minimum_bid": "*minimum_accepted_bid_in_smallest_denomination_of_bid_token*", "description": "*optional_text_description*"}' --from *your_key_alias_or_addr* --label *name_for_the_auction* --gas 300000 -y
```
You can find a contract's code hash with
```sh
secretcli q compute contract-hash *contract_address*
```
Copy it without the 0x prefix and surround it with quotes in the instantiate command.
For the tokens created using the default token protocol, the code hash is `e87c2d9ec2cc89f19b60e4b927b96d4e6b5a309200f4f303f96b666546dcea33`

The auction will not allow a sale amount of 0

### 3. Viewing the Auction Information
You can view the sell and bid token information, the amount being sold, the minimum bid, the description if present, the auction contract address, and the status of the auction with
```sh
secretcli q compute query *auction_contract_address* '{"auction_info":{}} | jq'
```
Piping through jq neatly prints the output.

The status will either be "Closed" if the auction is over, or it will be "Accepting bids".  If the auction is accepting bids, auction_info will also tell you if the auction owner has consigned the tokens to be sold to the auction. You may want to wait until the owner consigns the tokens before you bid, but there is no risk in doing it earlier.

### 4. Consigning Tokens To Be Sold
To consign the tokens to be sold, the owner should Send the tokens to the contract address with
```sh
secretcli tx compute execute *sale_tokens_contract_address* '{"send": {"recipient": "*auction_contract_address*", "amount": "*amount_being_sold_in_smallest_denomination_of_sell_token*"}}' --from *your_key_alias_or_addr* --gas 500000 -y
```
It will only accept consignment from the address that created the auction.  You can consign all the sale tokens together, or do so across several transactions, before or after placing bids.

### 5. Placing Bids
To place a bid, the bidder should Send the tokens to the contract address with
```sh
secretcli tx compute execute *bid_tokens_contract_address* '{"send": {"recipient": "*auction_contract_address*", "amount": "*bid_amount_in_smallest_denomination_of_bidding_token*"}}' --from *your_key_alias_or_addr* --gas 500000 -y
```
The tokens bid will be placed in escrow until the auction has concluded or you call retract\_bid to retract your bid and have all tokens returned.  You may retract your bid at any time before the auction ends. You may only have one active bid at a time.  If you place more than one bid, the smallest bid will be returned.  If you bid the same amount as your previous bid, it will retain your original bid's timestamp, because, in the event of ties, the bid placed earlier is deemed the winner.  If you place a bid that is less than the minimum bid, those tokens will be immediately returned to you.  Also, if you place a bid after the auction has closed, those tokens will be immediately returned.

The auction will not allow a bid of 0.

### 6. View Your Active Bid
You may view your current active bid amount and the time the bid was placed with
```sh
secretcli tx compute execute *auction_contract_address* '{"view_bid": {}}' --from *your_key_alias_or_addr* --gas 200000 -y
```
You must use the same address that you did the Send transaction with to view the bid. Any other address trying to view the bid will be declined access.

## 7. Retract Your Active Bid
You may retract your current active bid with
```sh
secretcli tx compute execute *auction_contract_address* '{"retract_bid": {}}' --from *your_key_alias_or_addr* --gas 300000 -y
```
You may retract your bid at any time before the auction closes to both retract your bid and to return your tokens.

### 8. Finalizing the Auction Sale
The auction creator may close an auction with
```sh
secretcli tx compute execute *auction_contract_address* '{"finalize": {"only_if_bids": *true_or_false*}}' --from *your_key_alias_or_addr* --gas 2000000 -y
```
Only the auction creator can finalize an auction.  The boolean only\_if\_bids parameter is used to prevent the auction from closing if there are no active bids.  If there are no active bids, but only\_if\_bids was set to false, then the auction will be closed, and all consigned tokens will be returned to the auction creator. 
If the auction is closed before the auction creator has consigned all the tokens for sale, any tokens consigned will be returned to the auction creator, and any active bids will be returned to the bidders.  If all the sale tokens have been consigned, and there is more than one active bid, then the highest bidder is considered the winner, and the amount to be payed by the winner is the amount he bidded if there is only one bidder, or the second highest bid amount, if more than one person placed a bid (if tied, the tying bid placed earlier will be accepted).  The auction will then swap the tokens between the auction creator and the highest bidder, and return all the non-winning bids to their respective bidders.

### 9. Viewing account balances
In order to view balances, the Secret Network requires additional viewing keys, which can be created by the following command:
```sh
secretcli tx snip20 create-viewing-key *bid_or_sell_tokens_contract_address* --from *your_key_alias_or_addr*
```
This will produce a transaction hash, from which you can get the viewing key by running
```sh
secretcli q compute tx *txHash*
```
And checking the value beginning with the term `api_key`. Viewing keys will be similar to this: `api_key_/JLxqJmQGQJB2zEzhWdCPHNghEQpGzFwNnsY1wnkmlo=`

Finally, the balance can be viewed by the following command:
```sh
secretcli q snip20 balance *bid_or_sell_tokens_contract_address* *your_key_addr(not_alias)* *viewing_key*
```

---

Following the above steps will allow you to sucessfully run the VCG auction we created on the secret network.
You can view a step by step simulation of the above procedure using the `auction.sh` script [here](./Assets/simulation.pdf)

