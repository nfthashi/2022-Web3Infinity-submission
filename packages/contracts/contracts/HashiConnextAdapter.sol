// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";

import "@connext/nxtp-contracts/contracts/core/connext/libraries/LibConnextStorage.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IExecutor.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnextHandler.sol";

//TODO: remove when prod
import "hardhat/console.sol";

contract HashiConnextAdapter is OwnableUpgradeable, ERC165Upgradeable {
  mapping(bytes32 => address) private _bridgeContracts;

  address private _connext;
  address private _executor;
  uint32 private _selfDomain;

  event BridgeSet(uint32 domain, uint32 version, address bridgeContract);

  modifier onlyExecutor(uint32 version) {
    require(msg.sender == _executor, "HashiConnextAdapter: sender invalid");
    uint32 domain = _getOrigin();
    address originSender = _getOriginSender();
    address expectedBridgeContract = getBridgeContract(domain, version);
    require(
      originSender == expectedBridgeContract,
      "HashiConnextAdapter: origin sender invalid"
    );
    _;
  }

  function setBridgeContract(
    uint32 domain,
    uint32 version,
    address bridgeContract
  ) public onlyOwner {
    bytes32 bridgeContractKey = _getBridgeKey(domain, version);
    require(
      _bridgeContracts[bridgeContractKey] == address(0x0),
      "HashiConnextAdaptor: bridge already registered"
    );
    _bridgeContracts[bridgeContractKey] = bridgeContract;
    emit BridgeSet(domain, version, bridgeContract);
  }

  function getConnext() public view returns (address) {
    return _connext;
  }

  function getExecutor() public view returns (address) {
    return _executor;
  }

  function getSelfDomain() public view returns (uint32) {
    return _selfDomain;
  }

  function getBridgeContract(uint32 domain, uint32 version) public view returns (address){
    bytes32 bridgeKey = _getBridgeKey(domain, version);
    return _bridgeContracts[bridgeKey];
  }

  // solhint-disable-next-line func-name-mixedcase
  function __HashiConnextAdapter_init(
    uint32 selfDomain,
    address connext
  ) internal onlyInitializing {
    __Ownable_init_unchained();
    __HashiConnextAdapter_init_unchained(selfDomain, connext);
  }

  // solhint-disable-next-line func-name-mixedcase
  function __HashiConnextAdapter_init_unchained(
    uint32 selfDomain,
    address connext
  ) internal onlyInitializing {
    _selfDomain = selfDomain;
    _connext = connext;
    _executor = address(IConnextHandler(_connext).executor());
  }

  function _getOrigin() internal returns (uint32) {
    return IExecutor(msg.sender).origin();
  }

  function _getOriginSender() internal returns (address) {
    return IExecutor(msg.sender).originSender();
  }

  function _xcall(
    uint32 destinationdomain,
    uint32 version,
    bytes memory callData
  ) internal {
    address destinationContract = getBridgeContract(destinationdomain, version);
    require(destinationContract != address(0x0), "HashiConnextAdapter: invalid bridge");
    CallParams memory callParams = CallParams({
      to: destinationContract,
      callData: callData,
      originDomain: _selfDomain,
      destinationDomain: destinationdomain,
      agent: msg.sender,
      recovery: msg.sender,
      forceSlow: false,
      receiveLocal: false,
      callback: address(0),
      callbackFee: 0,
      relayerFee: 0,
      slippageTol: 9995
    });
    XCallArgs memory xcallArgs = XCallArgs({params: callParams, transactingAssetId: address(0x0), amount: 0});
    IConnextHandler(_connext).xcall(xcallArgs);
  }

  function _getBridgeKey(uint32 domain, uint32 version) internal pure returns(bytes32){
    return keccak256(abi.encodePacked(domain, version));
  }
}