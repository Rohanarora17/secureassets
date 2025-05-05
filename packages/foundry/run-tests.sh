#!/bin/bash
# run-tests.sh

# Set RPC URLs for Base networks
export BASE_MAINNET_RPC_URL="https://mainnet.base.org"
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
export BASESCAN_API_KEY="your_api_key_here"

# Run unit tests (no network needed)
echo "Running unit tests..."
forge test --match-test "Test$" -v

# Run integration tests on Base Mainnet fork
echo "Running integration tests on Base Mainnet fork..."
forge test --match-path "**/integration/**" --fork-url $BASE_MAINNET_RPC_URL -v

# Run end-to-end tests on Base Mainnet fork
echo "Running end-to-end tests on Base Mainnet fork..."
forge test --match-path "**/e2e/**" --fork-url $BASE_MAINNET_RPC_URL -v

# Run integration tests on Base Sepolia fork
echo "Running integration tests on Base Sepolia fork..."
forge test --match-path "**/integration/**" --fork-url $BASE_SEPOLIA_RPC_URL -v
