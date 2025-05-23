/**
 * This file is autogenerated by Scaffold-ETH.
 * You should not edit it manually or your changes might be overwritten.
 */
import { GenericContractsDeclaration } from "~~/utils/scaffold-eth/contract";

const deployedContracts = {
  31337: {
    MockERC20: {
      address: "0x5fbdb2315678afecb367f032d93f642f64180aa3",
      abi: [
        {
          type: "constructor",
          inputs: [
            {
              name: "name",
              type: "string",
              internalType: "string",
            },
            {
              name: "symbol",
              type: "string",
              internalType: "string",
            },
            {
              name: "decimals_",
              type: "uint8",
              internalType: "uint8",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "allowance",
          inputs: [
            {
              name: "owner",
              type: "address",
              internalType: "address",
            },
            {
              name: "spender",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "approve",
          inputs: [
            {
              name: "spender",
              type: "address",
              internalType: "address",
            },
            {
              name: "value",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "bool",
              internalType: "bool",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "balanceOf",
          inputs: [
            {
              name: "account",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "burn",
          inputs: [
            {
              name: "from",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "decimals",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "uint8",
              internalType: "uint8",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "mint",
          inputs: [
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "name",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "string",
              internalType: "string",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "symbol",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "string",
              internalType: "string",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "totalSupply",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "transfer",
          inputs: [
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
            {
              name: "value",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "bool",
              internalType: "bool",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "transferFrom",
          inputs: [
            {
              name: "from",
              type: "address",
              internalType: "address",
            },
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
            {
              name: "value",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "bool",
              internalType: "bool",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "event",
          name: "Approval",
          inputs: [
            {
              name: "owner",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "spender",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "value",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "Transfer",
          inputs: [
            {
              name: "from",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "to",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "value",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
          ],
          anonymous: false,
        },
        {
          type: "error",
          name: "ERC20InsufficientAllowance",
          inputs: [
            {
              name: "spender",
              type: "address",
              internalType: "address",
            },
            {
              name: "allowance",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "needed",
              type: "uint256",
              internalType: "uint256",
            },
          ],
        },
        {
          type: "error",
          name: "ERC20InsufficientBalance",
          inputs: [
            {
              name: "sender",
              type: "address",
              internalType: "address",
            },
            {
              name: "balance",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "needed",
              type: "uint256",
              internalType: "uint256",
            },
          ],
        },
        {
          type: "error",
          name: "ERC20InvalidApprover",
          inputs: [
            {
              name: "approver",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "ERC20InvalidReceiver",
          inputs: [
            {
              name: "receiver",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "ERC20InvalidSender",
          inputs: [
            {
              name: "sender",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "ERC20InvalidSpender",
          inputs: [
            {
              name: "spender",
              type: "address",
              internalType: "address",
            },
          ],
        },
      ],
      inheritedFunctions: {},
      deploymentFile: "run-1746444296.json",
      deploymentScript: "Deploy.s.sol",
    },
    MockAavePool: {
      address: "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0",
      abi: [
        {
          type: "constructor",
          inputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "aTokens",
          inputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "addAsset",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "aToken",
              type: "address",
              internalType: "address",
            },
            {
              name: "liquidityRate",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "getReserveData",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "unbacked",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "accruedToTreasuryScaled",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "totalAToken",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "totalStableDebt",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "totalVariableDebt",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "liquidityRate",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "variableBorrowRate",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "stableBorrowRate",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "lastUpdateTimestamp",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "aTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "stableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "variableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "interestRateStrategyAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "id",
              type: "uint8",
              internalType: "uint8",
            },
            {
              name: "borrowCap",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "supplyCap",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "reserveFactor",
              type: "uint16",
              internalType: "uint16",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "liquidityRates",
          inputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "supply",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "onBehalfOf",
              type: "address",
              internalType: "address",
            },
            {
              name: "",
              type: "uint16",
              internalType: "uint16",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "withdraw",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "event",
          name: "Supplied",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
            {
              name: "onBehalfOf",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "Withdrawn",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
            {
              name: "to",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "error",
          name: "SafeERC20FailedOperation",
          inputs: [
            {
              name: "token",
              type: "address",
              internalType: "address",
            },
          ],
        },
      ],
      inheritedFunctions: {},
      deploymentFile: "run-1746444296.json",
      deploymentScript: "Deploy.s.sol",
    },
    MockAaveProtocolDataProvider: {
      address: "0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9",
      abi: [
        {
          type: "function",
          name: "getReserveData",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "configuration",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "liquidityIndex",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "currentLiquidityRate",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "variableBorrowIndex",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "currentVariableBorrowRate",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "currentStableBorrowRate",
              type: "uint128",
              internalType: "uint128",
            },
            {
              name: "lastUpdateTimestamp",
              type: "uint40",
              internalType: "uint40",
            },
            {
              name: "id",
              type: "uint16",
              internalType: "uint16",
            },
            {
              name: "aTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "stableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "variableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "interestRateStrategyAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "baseLTVasCollateral",
              type: "uint128",
              internalType: "uint128",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getReserveTokensAddresses",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "aTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "stableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
            {
              name: "variableDebtTokenAddress",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "setLiquidityRate",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "rate",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "setTokenAddresses",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "aToken",
              type: "address",
              internalType: "address",
            },
            {
              name: "stableDebtToken",
              type: "address",
              internalType: "address",
            },
            {
              name: "variableDebtToken",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
      ],
      inheritedFunctions: {},
      deploymentFile: "run-1746444296.json",
      deploymentScript: "Deploy.s.sol",
    },
    ModularVaultFactory: {
      address: "0x0165878a594ca255338adfa4d48449f69242eb8f",
      abi: [
        {
          type: "constructor",
          inputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "allVaults",
          inputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "createAaveAdapter",
          inputs: [
            {
              name: "aavePool",
              type: "address",
              internalType: "address",
            },
            {
              name: "dataProvider",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "adapter",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "createVault",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "name",
              type: "string",
              internalType: "string",
            },
            {
              name: "symbol",
              type: "string",
              internalType: "string",
            },
            {
              name: "protocolName",
              type: "string",
              internalType: "string",
            },
          ],
          outputs: [
            {
              name: "vault",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "getAllVaults",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "address[]",
              internalType: "address[]",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getProtocolCount",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getSupportedProtocols",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "string[]",
              internalType: "string[]",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getVaultCount",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "owner",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "protocolAdapters",
          inputs: [
            {
              name: "",
              type: "string",
              internalType: "string",
            },
          ],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "registerAdapter",
          inputs: [
            {
              name: "protocolName",
              type: "string",
              internalType: "string",
            },
            {
              name: "adapter",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "renounceOwnership",
          inputs: [],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "supportedProtocols",
          inputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "string",
              internalType: "string",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "transferOwnership",
          inputs: [
            {
              name: "newOwner",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "vaults",
          inputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "event",
          name: "AdapterRegistered",
          inputs: [
            {
              name: "protocol",
              type: "string",
              indexed: false,
              internalType: "string",
            },
            {
              name: "adapter",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "AdapterUpdated",
          inputs: [
            {
              name: "protocol",
              type: "string",
              indexed: false,
              internalType: "string",
            },
            {
              name: "oldAdapter",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "newAdapter",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "OwnershipTransferred",
          inputs: [
            {
              name: "previousOwner",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "newOwner",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "VaultCreated",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "vault",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "protocol",
              type: "string",
              indexed: false,
              internalType: "string",
            },
          ],
          anonymous: false,
        },
        {
          type: "error",
          name: "OwnableInvalidOwner",
          inputs: [
            {
              name: "owner",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "OwnableUnauthorizedAccount",
          inputs: [
            {
              name: "account",
              type: "address",
              internalType: "address",
            },
          ],
        },
      ],
      inheritedFunctions: {},
      deploymentFile: "run-1746444296.json",
      deploymentScript: "Deploy.s.sol",
    },
    AaveV3Adapter: {
      address: "0xa513e6e4b8f2a923d98304ec87f64353c4d5c853",
      abi: [
        {
          type: "constructor",
          inputs: [
            {
              name: "_aavePool",
              type: "address",
              internalType: "address",
            },
            {
              name: "_dataProvider",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "aavePool",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "dataProvider",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "deposit",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "getAPY",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getDepositToken",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "getSuppliedBalance",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "owner",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "address",
              internalType: "address",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "protocolName",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "string",
              internalType: "string",
            },
          ],
          stateMutability: "pure",
        },
        {
          type: "function",
          name: "recoverERC20",
          inputs: [
            {
              name: "token",
              type: "address",
              internalType: "address",
            },
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "referralCode",
          inputs: [],
          outputs: [
            {
              name: "",
              type: "uint16",
              internalType: "uint16",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "renounceOwnership",
          inputs: [],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "supportsAsset",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "bool",
              internalType: "bool",
            },
          ],
          stateMutability: "view",
        },
        {
          type: "function",
          name: "transferOwnership",
          inputs: [
            {
              name: "newOwner",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "updateAavePool",
          inputs: [
            {
              name: "_aavePool",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "updateDataProvider",
          inputs: [
            {
              name: "_dataProvider",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "updateReferralCode",
          inputs: [
            {
              name: "_referralCode",
              type: "uint16",
              internalType: "uint16",
            },
          ],
          outputs: [],
          stateMutability: "nonpayable",
        },
        {
          type: "function",
          name: "withdraw",
          inputs: [
            {
              name: "asset",
              type: "address",
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              internalType: "uint256",
            },
            {
              name: "to",
              type: "address",
              internalType: "address",
            },
          ],
          outputs: [
            {
              name: "",
              type: "uint256",
              internalType: "uint256",
            },
          ],
          stateMutability: "nonpayable",
        },
        {
          type: "event",
          name: "AssetSupported",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "supported",
              type: "bool",
              indexed: false,
              internalType: "bool",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "Deposited",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "OwnershipTransferred",
          inputs: [
            {
              name: "previousOwner",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "newOwner",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "event",
          name: "Withdrawn",
          inputs: [
            {
              name: "asset",
              type: "address",
              indexed: true,
              internalType: "address",
            },
            {
              name: "amount",
              type: "uint256",
              indexed: false,
              internalType: "uint256",
            },
            {
              name: "to",
              type: "address",
              indexed: true,
              internalType: "address",
            },
          ],
          anonymous: false,
        },
        {
          type: "error",
          name: "OwnableInvalidOwner",
          inputs: [
            {
              name: "owner",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "OwnableUnauthorizedAccount",
          inputs: [
            {
              name: "account",
              type: "address",
              internalType: "address",
            },
          ],
        },
        {
          type: "error",
          name: "SafeERC20FailedOperation",
          inputs: [
            {
              name: "token",
              type: "address",
              internalType: "address",
            },
          ],
        },
      ],
      inheritedFunctions: {},
      deploymentFile: "run-1746444296.json",
      deploymentScript: "Deploy.s.sol",
    },
  },
} as const;

export default deployedContracts satisfies GenericContractsDeclaration;
