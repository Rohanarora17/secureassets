const { execSync } = require('child_process');
const path = require('path');

// Start Anvil in the background
console.log('Starting Anvil...');
const anvil = execSync('anvil', { stdio: 'inherit' });

// Wait for Anvil to start
setTimeout(() => {
    try {
        // Deploy contracts
        console.log('Deploying contracts...');
        execSync('forge script script/Deploy.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast', {
            stdio: 'inherit'
        });
        
        console.log('Deployment complete!');
    } catch (error) {
        console.error('Deployment failed:', error);
    }
}, 2000); 