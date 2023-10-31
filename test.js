const Moralis = require("moralis").default;
const { EvmChain } = require("@moralisweb3/common-evm-utils");

const runApp = async () => {
await Moralis.start({
    apiKey: "sONhn24iVETZ1reMWZZfPnrucSB7PqTcZAOc9wZeZVzXZKbeYORy4UgLtPGbgvl6",
    // ...and any other configuration
});

const address = "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599";

const chain = EvmChain.ETHEREUM;
console.log(chain);

const response = await Moralis.EvmApi.token.getTokenPrice({
    address,
    chain,
});

// const response = await Moralis.EvmApi.token.getTokenPrice({
//     address,
//     chain,
// })

console.log(response.toJSON());
};

runApp();