pragma solidity 0.8.24;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IDysonRouter {
  function depositETH(address tokenOut, uint index, address to, uint minOutput, uint time) external payable returns (uint output);
  function withdraw(address pair, uint index, address to) external returns (uint token0Amt, uint token1Amt);
}

interface IDysonPair {
  struct Note {
      uint token0Amt;
      uint token1Amt;
      uint due;
  }
  function noteCount(address input) external view returns (uint output);
  function notes(address input, uint count) external view returns (Note memory output);
}

interface IERC20 {
  function transfer(address to, uint value) external returns (bool);
}

contract HigherSwap is Ownable {

  event DepositTo(address indexed pair, address indexed tokenOut, uint index, address to);
  event FullfillNote(address sender, address noteOwner, uint index);
  event WithdrawNote(address indexed pair, uint index, address to);

  constructor(address initialOwner) Ownable(initialOwner) {

  }
  /// TODO: we should support all pair instead of hardcode ETH pair and
  /// rely on off-chain function parameters
  mapping(address => mapping(uint => IDysonPair.Note)) public userNotes;
  mapping(uint => IDysonPair.Note) public protocolNotes;

  /// @notice Deposit ETH
  /// Deposit ETH into Dyson's dual investment.
  /// For our users they should treat this as place a limit order.
  function depositTo(address router, address pair, address tokenOut, uint index, address to, uint minOutput, uint time) public payable {
    uint positionIndex = IDysonPair(pair).noteCount(address(this));
    IDysonRouter(router).depositETH{value: msg.value}(tokenOut, index, to, minOutput, time);
    userNotes[msg.sender][positionIndex] = IDysonPair(pair).notes(address(this), positionIndex);
    emit DepositTo(pair, tokenOut, index, to);
  }

  /// @notice Fullfill limit order
  /// If the limit order hit it's strike price, anyone can call
  /// this function to fulllfill the order and get some DYSN reward.
  /// TODO: implement DYSN
  function fullfillNote(address noteOwner, uint index, address fullfillTokenAddress, bool fullfillToken0) public {
    IDysonPair.Note memory note = userNotes[noteOwner][index];
    require(note.due != 0, "Empty note");
    // TODO: add oracle price check to ensure the userNotes should be fullfilled
    IERC20(fullfillTokenAddress).transfer(noteOwner, fullfillToken0 ? note.token0Amt : note.token1Amt);

    protocolNotes[index] = note;
    delete userNotes[noteOwner][index];
    emit FullfillNote(msg.sender, noteOwner, index);
  }

  /// @notice Handle protocol owned order
  /// Only owner can call.
  function handleProtocolNote(address router, address pair, uint index, address to) public onlyOwner {
    IDysonRouter(router).withdraw(pair, index, to);
    delete protocolNotes[index];
    emit WithdrawNote(pair, index, to);
  }
}