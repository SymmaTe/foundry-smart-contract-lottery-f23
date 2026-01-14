//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        bool enableNativePayment;
        address link;
        uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activateNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activateNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activateNetworkConfig = getMainnetEthConfig();
        } else {
            activateNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 70171100616832042798067778232486843270290247212512339725323436114001014490010, //update with our subscription id
                callbackGasLimit: 500000,
                enableNativePayment: false,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activateNetworkConfig.vrfCoordinator != address(0)) {
            return activateNetworkConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;
        int256 weiPerUnitLink = 4e15;
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
                baseFee,
                gasPriceLink,
                weiPerUnitLink
            );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vrfCoordinatorV2_5Mock),
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0, //update with our subscription id
                callbackGasLimit: 500000,
                enableNativePayment: false,
                link: address(link),
                deployerKey: DEFAULT_ANVIL_KEY
            });
    }

    function getMainnetEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a,
                gasLane: 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b,
                subscriptionId: 0, //update with our subscription id
                callbackGasLimit: 500000,
                enableNativePayment: false,
                link: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }
}
