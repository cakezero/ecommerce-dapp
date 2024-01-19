// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract EsContract is VRFConsumerBaseV2, ConfirmedOwner {
    // uint public sellerStake = 0.25 * (10 ** 18);
	uint64 subsId;
	uint32 callbackGasLimit = 100000;
	uint8 numWords = 1;
	uint8 confirmations = 5;

    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    VRFCoordinatorV2Interface COORDINATOR;

    mapping (address => bool) private isSeller;
    mapping (address => uint256) private sender;
    mapping (address => bool) private hasDelivered;
    mapping (address => uint256) private sellerInfo;
    mapping (address => uint256) sellerFunds;
    mapping (uint => s_requests) public reqs;

    struct s_requests {
        bool exists;
        bool fulfilled;
        uint256[] randomWords;
    }

    event Paid(address indexed reciever, string text, uint amount);
    event RequestFulfilled(uint256 reqId, uint256[] randomWords);

    constructor(uint64 _subsId) VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625) ConfirmedOwner(msg.sender) {
    	COORDINATOR = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
        subsId = _subsId;
    }

	function generateId() internal returns (uint256 reqId) {
		reqId = COORDINATOR.requestRandomWords(keyHash, subsId, confirmations, callbackGasLimit, numWords);
        reqs[reqId] = s_requests({
            randomWords: new uint256[](0),
            fulfilled: false,
            exists: true
        });
		return reqId;
	}

    function fulfillRandomWords(uint256 reqId, uint256[] memory randomWords) internal override {
        require(reqs[reqId].exists == true, 'Id not found');
        reqs[reqId].fulfilled = true;
        reqs[reqId].randomWords = randomWords;
        emit RequestFulfilled(reqId, randomWords);
    }

    function createSeller(address seller) external payable {
        // require(msg.value == sellerStake, 'You did not send the required amount');
		uint id = generateId();
        sender[msg.sender] = msg.value;
        isSeller[seller] = true;
        sellerInfo[seller] = id;
    }

    function delivered(address[] calldata sellers) external {
        for (uint i = 0; i < sellers.length; i++) {
            if (isSeller[sellers[i]] == true) {
                hasDelivered[sellers[i]] = true;
            } else {
                revert('Address is not a Seller');
            }
        }
    }

    function allocateFunds(address[] memory sellersAddy, uint[] memory funds) external {
        for (uint i = 0; i < sellersAddy.length; i++) {
            require(isSeller[sellersAddy[i]] == true, 'You are not a seller');
            sellerFunds[sellersAddy[i]] = funds[i];
        }
    }

    function claim(uint _amount, uint256 id) external onlySeller {
        require(sellerInfo[msg.sender] == id, 'You are not a seller');
        require(hasDelivered[msg.sender] == true, 'You have not yet delivered the product');
        require(sellerFunds[msg.sender] >= _amount, 'Insufficient Balance');
        uint amount = _amount * 2/100;
        _amount -= amount;
        (bool sent, ) = msg.sender.call{ value: _amount }("");
        require(sent);
        string memory mess = 'has been paid';
        emit Paid(msg.sender, mess, amount);
    }

    receive() external payable {}
    
    modifier onlySeller() {
        require(isSeller[msg.sender] == true, 'You are not a dealer');
        _;
    }
}
