// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";

contract EsContract is FunctionsClient, VRFConsumerBaseV2, ConfirmedOwner {

	uint8 numWords = 1;
	uint8 confirmations = 3;
	uint32 callbackGasLimit = 100000;
    uint64 subsId;
	
    bytes32 keyHash;
    VRFCoordinatorV2Interface COORDINATOR;
    IRouterClient public immutable ccipRouter;
    IERC20 public immutable usdc;

    // 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c keyHash

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
    mapping (uint => s_requests) public reqs;
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
    struct s_requests {
        bool exists;
        bool fulfilled;
        uint256[] randomWords;
    }

    address[] public merc;
    uint64[] public chain;
    address[] public cont;

    event CommissionPaid(address indexed receiver, uint amount);
    event MerchantCreated(address indexed merchant);
    event MerchantRemoved(address indexed merchant);
    event MoneySent(address indexed reciever, uint amount);
    event Paid(address indexed sender, uint amount);
    event RequestFulfilled(uint256 reqId, uint256[] randomWords);


    constructor(address _ccipRouter, address _usdc, uint64 _subsId, bytes32 _keyHash, address _vrfCoordinator ) VRFConsumerBaseV2(_vrfCoordinator) ConfirmedOwner(msg.sender){
        usdc = IERC20(_usdc);
        ccipRouter = IRouterClient(_ccipRouter);
        COORDINATOR = VRFCooordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
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

    function CreateMerchant(uint64 _chainSelector, address _UsdcContract) external {
        merchantDetail[msg.sender] = MerchantDetail({
            merchant: msg.sender,
            ChainSelector: _chainSelector,
            UsdcContract: _UsdcContract
        });
        emit MerchantCreated(msg.sender);
    }

    function RemoveMerchant(address _merchant) external onlyOwner {
        // merchants[_merchant] = false;
        emit MerchantRemoved(_merchant);
    }

    function deposit(uint amount, uint[] memory prices, address[] memory _merchants) external payable {
        uint Id = generateId();
        uint id = reqs[Id].randomWords[0];
        if (msg.value != amount) revert SendRequiredAmount();
        for (uint i = 0; i < _merchants.length; i++) {
            merc.push(merchantDetail[_merchants[i]].merchant);
            chain.push(merchantDetail[_merchants[i]].ChainSelector);
            cont.push(merchantDetail[_merchants[i]].UsdcContract);
        }
        Order[id] = order({
            merchants: merc,
            prices: prices,
            ChainSelectors: chain,
            UsdcContracts: cont
        });
    }

    function PayMerchant(uint64 _ChainSelector, address _receiver, address _token) external onlyMerchant returns(bytes32 messageId) {
        
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
