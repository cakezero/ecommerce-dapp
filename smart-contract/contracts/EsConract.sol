// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";

contract EsContract is ConfirmedOwner {

    IRouterClient public immutable ccipRouter;
    IERC20 public immutable usdc;
    address public immutable usdcContract;
    uint64 public immutable chainSelector;

    IERC20 public immutable linkToken;

    error FailedToWithdraw();
    error InvalidAddress();
    error NotASeller(address phony);
    error NotEnoughFeesForGas(uint balance, uint fees);
    error NothingToWithdraw();
    error OrderHasBeenFulfilled();
    error SendRequiredAmount();

    mapping(address => uint256) internal commission;
    mapping(address => bool) public isSeller;
    mapping(bytes8 => Order) internal order;

    struct Order {
        address[] sellers;
        uint[] prices;
    }

    event CommissionPaid(address indexed receiver, uint amount);
    event SellerCreated(address indexed seller);
    event SellerRemoved(address indexed seller);
    event MoneySent(address indexed reciever, uint amount);
    event MoneyDeposited(address indexed depositor, uint amount);
    event Paid(bytes32 indexed messageId, address indexed receiver, uint amount);

    constructor(address _ccipRouter, address _usdc, uint64 _chainSelector, address _linkToken) ConfirmedOwner(msg.sender) {
        usdc = IERC20(_usdc);
        ccipRouter = IRouterClient(_ccipRouter);
        usdcContract = _usdc;
        linkToken = IERC20(_linkToken);
        chainSelector = _chainSelector;
    }

    function CreateSeller() external onlyOwner {
        isSeller[msg.sender] = true;
        emit SellerCreated(msg.sender);
    }

    function deposit(
        uint amount,
        uint[] memory prices,
        address[] memory _sellers,
        string calldata orderId
    ) external payable {
        if (msg.value != amount) revert SendRequiredAmount();
        for (uint i = 0; i < _sellers.length; i++) {
            if (isSeller[_sellers[i]]) revert NotASeller(_sellers[i]);
            if (_sellers[i] == address(0)) revert InvalidAddress();
        }
        order[orderId] = Order({
            sellers: _sellers,
            prices: prices
        });

        payConfirmed[orderId] = false;
        emit MoneyDeposited(msg.sender, amount);
    }

    function PaySeller(string calldata id) external onlyOwner {
        if (payConfirmed[id)) revert OrderHasBeenFulfilled();

        Order storage orderDetails = order[id];

        for (uint i = 0; i < orderDetails.sellers.length; i++) {
            uint _amount = orderDetails.prices[i] * 1/100; // Takes 1% for commission 
            orderDetails.prices[i] -= _amount;

            Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
            Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
                token: usdcContract,
                amount:  orderDetails.prices[i]
            });
            tokenAmounts[0] = tokenAmount;

            Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
                receiver: abi.encode(orderDetails.sellers[i]),
                tokenAmounts: tokenAmounts,
                data: "",
                extraArgs: "",
                feeToken: address(linkToken) // uses Link for gas
            });
            uint256 fees = ccipRouter.getFee(chainSelector, evm2AnyMessage);

            if (fees > linkToken.balanceOf(address(this))) 
                revert NotEnoughFeesForGas(linkToken.balanceOf(address(this)), fees);

            linkToken.approve(address(ccipRouter), fees);

            usdc.approve(address(ccipRouter), orderDetails.prices[i]);

            bytes32 messageId = ccipRouter.ccipSend(chainSelector, evm2AnyMessage);

            payConfirmed[id] = true;

            emit Paid(messageId, orderDetails.sellers[i], orderDetails.prices[i]);
        }
    }

    function checkCommission() public view onlyOwner returns (uint amount) {
        amount = commission[msg.sender];
    }

    function withdrawCommission() external onlyOwner {
        uint amount = checkCommission();
        if (amount == 0) revert NothingToWithdraw();
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        if (!sent) revert FailedToWithdraw();
        emit CommissionPaid(msg.sender, amount);
    }

    receive() external payable {}

    modifier onlySeller() {
        require(isSeller[msg.sender], "You are not a seller");
        _;
    }
}
