//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,,,,,, uint256 deployerKey) = helperConfig.activateNetworkConfig();
        return createSubscription(vrfCoordinator, deployerKey);
    }

    function createSubscription(address vrfCoordinator, uint256 deployerKey) public returns (uint256) {
        console.log("Creating subscription on chainId:", block.chainid);
        vm.startBroadcast(deployerKey);
        uint256 subId = IVRFCoordinatorV2Plus(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Subscription created with id:", subId);
        console.log("Please update the HelperConfig.s.sol file with this subId");
        return subId;
    }

    function run() external {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 100 ether;

    function fundSubscriptionUsingConfig() public payable {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,, uint256 subscriptionId,,, address link, uint256 deployerKey) =
            helperConfig.activateNetworkConfig();
        fundSubscription(vrfCoordinator, subscriptionId, link, deployerKey);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address link, uint256 deployerKey)
        public
        payable
    {
        console.log("Funding subscription on chainId:", block.chainid);
        console.log("Using VRF Coordinator at:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
            console.log("Subscription funded with:", FUND_AMOUNT, "LINK");
        } else {
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
            console.log("Subscription funded with:", FUND_AMOUNT, "LINK");
        }
    }

    function run() external payable {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (,, address vrfCoordinator,, uint256 subscriptionId,,,, uint256 deployerKey) =
            helperConfig.activateNetworkConfig();
        addConsumer(vrfCoordinator, subscriptionId, raffle, deployerKey);
    }

    function addConsumer(address vrfCoordinator, uint256 subscriptionId, address raffle, uint256 deployerKey) public {
        console.log("Adding consumer on chainId:", block.chainid);
        console.log("Using VRF Coordinator at:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);
        console.log("Consumer address:", raffle);
        vm.startBroadcast(deployerKey);
        IVRFCoordinatorV2Plus(vrfCoordinator).addConsumer(subscriptionId, raffle);
        vm.stopBroadcast();
        console.log("Consumer added to subscription:", subscriptionId);
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(raffle);
    }
}
