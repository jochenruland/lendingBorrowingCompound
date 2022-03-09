pragma solidity ^0.8.10;

interface IComptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
}

interface IPriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}
