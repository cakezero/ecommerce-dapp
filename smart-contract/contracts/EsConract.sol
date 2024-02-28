// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract EsContract is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    IRouterClient public immutable ccipRouter;
    IERC20 public immutable usdc;
    address public immutable usdcContract;
    uint64 public immutable chainSelector;

    IERC20 public linkToken;

    error NotEnoughFeesForGas(uint balance, uint fees);
    error NothingToWithdraw();
    error FailedToWithdraw();
    error InvalidAddress();
    error NotAMerchant(address phony);
    error SendRequiredAmount();
    error NotYetDelivered();

    mapping(address => uint256) internal commission;
    mapping(address => bool) public isMerchant;
    mapping(bytes8 => order) external Order;

    struct order {
        address[] merchants;
        uint[] prices;
    }

    event CommissionPaid(address indexed receiver, uint amount);
    event MerchantCreated(address indexed merchant);
    event MerchantRemoved(address indexed merchant);
    event MoneySent(address indexed reciever, uint amount);
    event Paid(bytes32indexed messageId, address indexed receiver, uint amount);

    constructor(address _ccipRouter, address _usdc, address _functionsRouter, uint64 _chainSelector, address _linkToken) FunctionsClient(_functionsRouter) ConfirmedOwner(msg.sender) {
        usdc = IERC20(_usdc);
        ccipRouter = IRouterClient(_ccipRouter);
        usdcContract = _usdc;
        linkToken = IERC20(_linkToken);
        chainSelector = _chainSelector
    }

    function generateId() internal view returns (bytes8 id) {
        bytes32 blockHash = blockhash(block.number - 1);
        id = bytes8(keccak256(abi.encodePacked(blockHash)));
        return id;
    }

    function CreateMerchant() external {
        isMerchant[msg.sender] = true;
        emit MerchantCreated(msg.sender);
    }

    function deposit(
        uint amount,
        uint[] memory prices,
        address[] memory _merchants
    ) external payable returns (bytes8 id) {
        id = generateId();
        if (msg.value != amount) revert SendRequiredAmount();
        for (uint i = 0; i < _merchants.length; i++) {
            if (isMerchant[_merchants[i]]) revert NotAMerchant(_merchants[i]);
            if (_merchants[i] != address(0)) revert InvalidAddress();
        }
        Order[id] = order({
            merchants: _merchants,
            prices: prices,
        });
        return id;
    }

    function requestPayment(bytes memory request, uint64 subscriptionId, uint32 gasLimit, bytes32 donID) external returns (bytes32 messageId) {
       messageId = _sendRequest(request, subscriptionId, gasLimit, donID)
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        string memory delivered = abi.decode(response);
        
    }

    function PayMerchant(bytes8 id) internal {
        orderDetails = order[id];
        for (uint i = 0; i < orderDetails.merchants; i++) {
            uint _amount = orderDetails.prices[i] * 1/100; // Takes 1% for commission 
            orderDetails.prices[i] -= _amount;
            Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
                receiver: orderDetails.merchants[i],
                token: usdcContract;
                amount: orderDetails.prices[i],
                feeToken: address(linkToken) // uses Link
            );
            uint256 fees = ccipRouter.getFee(chainSelector, evm2AnyMessage);
            if (fees > linkToken.balanceOf(address(this))) revert NotEnoughFeesForGas(linkToken.balanceOf(address(this)), fees);

            linkToken.approve(address(ccipRouter), fees);

            usdc.approve(address(ccipRouter), orderDetails.prices[i]);

            bytes32 messageId = ccipRouter.ccipSend(chainSelector, evm2AnyMessage);

            emit Paid(messageId, receorderDetails.merchants[i], orderDetails.prices[i]);
        }
    }

    function checkCommission() external view onlyOwner returns (uint amount) {
        amount = commission[msg.sender];
    }

    function withdrawCommission() external onlyOwner {
        uint amount = commission[msg.sender];
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent);
        emit CommissionPaid(msg.sender, amount);
    }

    receive() external payable {}

    modifier onlyMerchant() {
        require(isMerchant[msg.sender], "You are not a merchant");
        _;
    }
}
