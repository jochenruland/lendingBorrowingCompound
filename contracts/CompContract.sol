// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import a couple of interfaces
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./ComptrollerInterface.sol";
import "./CTokenInterface.sol";


contract Comp {

  IERC20 dai;
  ICErc20 cDai;
  IERC20 bToken;
  ICErc20 cBToken;
  IComptroller comptroller;
  IPriceFeed priceFeed;

  address admin;

  event LogProcess(string, uint256);

  // Addresses deoend on network you are deploying to
  constructor(address _dai, address _cDai, address _bToken, address _cBToken, address _comptroller) {
    dai = IERC20(_dai);
    cDai = ICErc20(_cDai);
    bToken = IERC20(_bToken);
    cBToken = ICErc20(_cBToken);
    comptroller = IComptroller(_comptroller);

    admin = msg.sender;
  }

  // 1. Provide collateral to compound protocol
  function investDai(uint256 daiAmount) external {
    // the SC needs to have Dai first
    dai.approve(address(cDai), daiAmount);
    // This calls the ERC20 transferFrom() from the Dai token -> therefore we must approve frist
    cDai.mint(daiAmount);
    // After calling the mint function the SC owns cDai and earns interest on the investment
  }

  function cashOut() external {
    // request the total amount of cDai which consists of investment plus interets
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);
  }

  function borrow(uint256 daiCollateral) external returns(uint256) {
    // the SC needs to have Dai first
    dai.approve(address(cDai), daiCollateral);
    // This calls the ERC20 transferFrom() from the Dai token -> therefore we must approve frist
    cDai.mint(daiCollateral);
    // After calling the mint function the SC owns cDai and earns interest on the investment

    // Signal to compound protocol that we want to use some of our invested token as collateral for our loan
    address[] memory markets = new address[](1);
    markets[0] = address(cDai);
    uint256[] memory errors = comptroller.enterMarkets(markets); // Function takes an a array of token addresses which we have to create first
    if (errors[0] != 0) {
      revert('comptroller.enterMarkets() failed');
    }

    //find out how much of your borrow token you can get for your collateral amount
    (uint256 error2, uint256 maxLiquidity, uint256 shortfall) = comptroller.getAccountLiquidity(address(this));
    if (error2 != 0) {
      revert('comptroller.getAccountLiquidity() failed.');
    }
    require(shortfall == 0, "Account underwater");
    require(liquidity >0, "Account does not have excess collateral");
    emit LogProcess("Account has liquidity of: ", liquidity);

    //find out collateral factor for token you want to borrow
    (bool isListed, uint256 collateralFactor)= comptroller.markets(bToken);
    emit LogProcess("CollateralFactor for bToken:", collateralFactor);

    //get borrow rate added to the borrow Amount each block
    uint256 borrowRate = cBToken.borrowRatePerBlock();
    emit LogProcess("Current borrow rate per block for btoken: ", borrowRate);

    uint256 collateralPrice = priceFeed.getUnderlyingPrice(address(cBToken));
    uint256 maxBorrow = liquidity/collateralPrice;
    emit LogProcess("Maximum Amount of bToken to borrow (You should borrow far less): " maxBorrow);

    uint256 borrowAmount = maxBorrow * 30 / 100;


    // when borrowing, the amount must be inferior to the collateral minus the collateral factor; must be caluculated first!!!
    cBToken.borrow(borrowAmount * 10**18);

    // get actual borrow balance
    uint256 currentBorrow = cBToken.borrowBalanceCurrent(address(this));
    emit LogProcess("Current amount borrowed of bToken: " currentBorrow);

    return currentBorrow;

  }

  function payback() external {
    // before repaying the loan we must approve the cBat contract to take our bat tokens plus the amount of interests (you can calculate the interest before)
    btoken.approve(address(cBToken), 120);
    cBToken.repayBorrow(100);

    //Optional: reimburse collateral immediately as part of this function
    // request the total amount of cDai which consists of investment plus interets
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);

  }
}
