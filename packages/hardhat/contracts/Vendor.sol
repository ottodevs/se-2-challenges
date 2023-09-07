pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
	uint256 public constant tokensPerEth = 100;

	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		uint256 tokensToBuy = msg.value * tokensPerEth;
		console.log("tokens to buy", tokensToBuy);
		require(
			yourToken.balanceOf(address(this)) >= tokensToBuy,
			"Vendor: Not enough tokens in contract"
		);

		yourToken.transfer(msg.sender, tokensToBuy);
		emit BuyTokens(msg.sender, msg.value, tokensToBuy);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) external {
		require(
			yourToken.balanceOf(msg.sender) >= _amount,
			"Vendor: Not enough tokens to sell"
		);
		require(
			yourToken.allowance(msg.sender, address(this)) >= _amount,
			"Vendor: Allowance too low"
		);

		uint256 ethToTransfer = _amount / tokensPerEth;
		require(
			address(this).balance >= ethToTransfer,
			"Vendor: Not enough ETH in contract to buy tokens"
		);

		yourToken.transferFrom(msg.sender, address(this), _amount);
		payable(msg.sender).transfer(ethToTransfer);

		emit SellTokens(msg.sender, _amount, ethToTransfer);
	}
}
