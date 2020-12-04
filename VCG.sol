// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

contract SimpleAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    address payable public highestBidder;
    uint public highestBid = 0;
    uint private secondHighestBid = 0;

    mapping(address => uint) pendingReturns;

    bool ended = false;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _biddingTime,
        address payable _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(
            block.timestamp <= auctionEndTime,
            "Auction already ended."
        );

        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        secondHighestBid = highestBid;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {

            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {

        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        ended = true;
        beneficiary.transfer(secondHighestBid);
        highestBidder.transfer(highestBid-secondHighestBid);
        emit AuctionEnded(highestBidder, highestBid);
    }
}