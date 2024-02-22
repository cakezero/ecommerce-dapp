// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";


contract EsContract is FunctionsClient, ConfirmedOwner {
	
    IRouterClient public immutable ccipRouter;
    IERC20 public immutable usdc;

    error NotEnoughFeesForGas(uint balance, uint fees);
    error NothingToWithdraw();
    error FailedToWithdraw();
    error ChainNotSupported();
    error InvalidAddress();
    error NotAMerchant();    
    error SendRequiredAmount();

    mapping (uint64 => bool) public allowlistedChains;
    mapping (address => uint256) internal commission;
    mapping (address => bool) public isMerchant;
    mapping (address => MerchantDetail) internal merchantDetail;
    mapping (address => uint256) internal MerchantPayment;
    mapping (uint256 => order) internal Order;

    struct MerchantDetail {
        address merchant;
        uint64 ChainSelector;
        address UsdcContract;
    }
    struct order {
        address[] merchants;
        uint64[] ChainSelectors;
        address[] UsdcContracts;
        uint[] prices;
    }

    address[] public merc;
    uint64[] public chain;
    address[] public cont;

    event CommissionPaid(address indexed receiver, uint amount);
    event MerchantCreated(address indexed merchant);
    event MerchantRemoved(address indexed merchant);
    event MoneySent(address indexed reciever, uint amount);
    event Paid(address indexed sender, uint amount);


    constructor(address _ccipRouter, address _usdc) ConfirmedOwner(msg.sender){
        usdc = IERC20(_usdc);
        ccipRouter = IRouterClient(_ccipRouter);
    }

    function CreateMerchant(uint64 _chainSelector, address _UsdcContract) external {
        merchantDetail[msg.sender] = MerchantDetail({
            merchant: msg.sender,
            ChainSelector: _chainSelector,
            UsdcContract: _UsdcContract
        });
        emit MerchantCreated(msg.sender);
    }

    function deposit(uint amount, uint[] memory prices, address[] memory _merchants) external payable returns (bytes8 id) {
        id = generateId();
        if (msg.value != amount) revert SendRequiredAmount();
        address[] hu = new address[](_merchants.length);
        for (uint i = 0; i < _merchants.length; i++) {
            hu.push(merchantDetail[_merchants[i]].merchant);
            chain.push(merchantDetail[_merchants[i]].ChainSelector);
            cont.push(merchantDetail[_merchants[i]].UsdcContract);
        }
        Order[id] = order({
            merchants: merc,
            prices: prices,
            ChainSelectors: chain,
            UsdcContracts: cont
        });

        return id;
    }

    function PayMerchant(uint256 id) external returns(bytes32 messageId) {
        
    }

    function checkCommission() external view onlyOwner returns (uint amount) {
        amount = commission[msg.sender];
        return amount;
    }

    function withdrawCommission() external onlyOwner {
        uint amount = commission[msg.sender];
        (bool sent, ) = payable(msg.sender).call{ value: amount }("");
        require(sent);
        emit CommissionPaid(msg.sender, amount);
    }

    receive() external payable {}

    modifier onlyMerchant() {
        require(isMerchant[msg.sender], 'You are not a merchant');
        _;
    }
}
