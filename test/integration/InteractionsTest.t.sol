//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract InteractionsTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;
    DeployRaffle deployer;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    bool enableNativePayment;
    address link;

    uint96 public constant FUND_AMOUNT = 100 ether;

    modifier onlyOnAnvilChain() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    function setUp() external {
        deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (entranceFee, interval, vrfCoordinator, gasLane,, callbackGasLimit, enableNativePayment, link,) =
            helperConfig.activateNetworkConfig();
        subscriptionId = raffle.getSubscriptionId();
    }

    function testDeployRaffleCreatesRaffleWithCorrectParams() public view {
        assertEq(raffle.getEntranceFee(), entranceFee);
        assertEq(raffle.getInterval(), interval);
        assertEq(raffle.getVrfCoordinator(), vrfCoordinator);
        assertEq(raffle.getGasLane(), gasLane);
        assertEq(raffle.getSubscriptionId(), subscriptionId);
        assertEq(raffle.getCallbackGasLimit(), callbackGasLimit);
        assertEq(raffle.getEnableNativePayment(), enableNativePayment);
    }

    function testCreateSubscriptionAndFundSubscriptionAndAddConsumer() public view onlyOnAnvilChain {
        (uint96 balance,, uint64 reqCount, address subOwner, address[] memory consumers) =
            VRFCoordinatorV2_5Mock(payable(vrfCoordinator)).getSubscription(subscriptionId);

        console.log("Subscription ID:", subscriptionId);
        console.log("LINK balance (human readable):", uint256(balance) / 1e18, "LINK");
        console.log("Request count:", reqCount);
        console.log("Owner:", subOwner);
        console.log("Consumer address count:", consumers.length);
        console.log("First consumer address:", consumers.length > 0 ? consumers[0] : address(0));
        assert(balance == FUND_AMOUNT);
        assert(subscriptionId != 0);
        assertEq(consumers[0], address(raffle));
        console.log("CreateSubscription and FundSubscription scripts executed successfully on Anvil chain.");
    }
}
