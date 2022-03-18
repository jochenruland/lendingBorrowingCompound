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

  address addrCDai;
  address admin;

  event LogProcess(string, uint256);

  // Addresses deoend on network you are deploying to
  constructor() {
    admin = msg.sender;
  }

  // 0. Initialize pointer to compound and erc20 contracts
  function initialize(address _dai, address _cDai, address _bToken, address _cBToken, address _comptroller, address _priceFeed) external onlyAdmin {
    dai = IERC20(_dai);
    cDai = ICErc20(_cDai);
    bToken = IERC20(_bToken);
    cBToken = ICErc20(_cBToken);
    comptroller = IComptroller(_comptroller);
    priceFeed = IPriceFeed(_priceFeed);
    addrCDai = _cDai;

  }

  // 1. Provide collateral to compound protocol
  function investDai(uint256 daiAmount) external onlyAdmin {
    // the SC needs to have Dai first
    dai.approve(addrCDai, daiAmount);
    // This calls the ERC20 transferFrom() from the Dai token -> therefore we must approve frist
    uint error0 = cDai.mint(daiAmount);
    require(error0 == 0, "cDai.mint Error");
    // After calling the mint function the SC owns cDai and earns interest on the investment
  }

  function cashOut() external onlyAdmin {
    // request the total amount of cDai which consists of investment plus interets
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);
  }

  function borrow(uint256 daiCollateral) external onlyAdmin returns(uint256) {
    // the SC needs to have Dai first

    // This calls the ERC20 transferFrom() from the Dai token -> therefore we must approve frist
    dai.approve(addrCDai, daiCollateral);

    // After calling the mint function the SC owns cDai and earns interest on the investment
    uint256 error1 = cDai.mint(daiCollateral);
    require(error1 == 0, 'cDai.mint() failed');

    // Signal to compound protocol that we want to use some of our invested token as collateral for our loan
    address[] memory markets = new address[](1);
    markets[0] = addrCDai;
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
    require(maxLiquidity > 0, "Account does not have excess collateral");
    emit LogProcess("Account has liquidity of: ", maxLiquidity);

    //find out collateral factor for token you want to borrow
    (bool isListed, uint256 collateralFactor) = comptroller.markets(addrCDai);
    emit LogProcess("CollateralFactor for bToken:", collateralFactor);


    //get borrow rate added to the borrow amount each block
    uint256 borrowRate = cBToken.borrowRatePerBlock();
    emit LogProcess("Current borrow rate per block for btoken: ", borrowRate);

    uint256 collateralPrice = priceFeed.getUnderlyingPrice(addrCDai);
    emit LogProcess("CollateralPrice: ", collateralPrice);

    uint256 maxBorrow = maxLiquidity/collateralPrice;
    emit LogProcess("Maximum Amount of bToken to borrow (You should borrow far less): ", maxBorrow);

    uint256 borrowAmount = maxBorrow * 80 / 100;
    emit LogProcess("borrowAmount calculated as 80% of maxBorrow): ", borrowAmount);

    // when borrowing, the amount must be inferior to the collateral minus the collateral factor; must be caluculated first!!!
    require(cBToken.borrow(5 * 10**18) == 0, "got collateral?");

    // get actual borrow balance
    uint256 currentBorrow = cBToken.borrowBalanceCurrent(address(this));
    emit LogProcess("Current amount borrowed of bToken: ", currentBorrow);

    return currentBorrow; 

  }

  function payback() external onlyAdmin {
    // before repaying the loan we must approve the cBat contract to take our bat tokens plus the amount of interests (you can calculate the interest before)
    bToken.approve(address(cBToken), 120);
    cBToken.repayBorrow(100);

    //Optional: reimburse collateral immediately as part of this function
    // request the total amount of cDai which consists of investment plus interets
    uint balance = cDai.balanceOf(address(this));
    cDai.redeem(balance);

  }

  modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can call the function");
    _;
  }
}
