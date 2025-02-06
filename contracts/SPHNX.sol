// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.26;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: SPHNX.sol

pragma solidity ^0.8.13;

contract SPHNX is Ownable, Pausable {
    // State variables
    uint256 public messagePrice;
    uint256 public messagesProcessed;
    address public winner;

    // Constants for withdrawal splits
    uint256 private constant WINNER_SHARE = 70;
    uint256 private constant OWNER_SHARE = 30;

    // Mapping to track user's paid messages
    mapping(address => uint256) public userMessages;
    // Mapping to track if a transaction hash has been used
    mapping(bytes32 => bool) public usedTransactionHashes;

    // Events
    event MessagePaid(address indexed user, uint256 amount, uint256 timestamp);
    event PriceUpdated(uint256 newPrice);
    event FundsWithdrawn(address indexed to, uint256 amount);
    event WinnerSet(address indexed winner);
    event WinnerWithdrawal(address indexed winner, uint256 amount);
    event OwnerWithdrawal(address indexed owner, uint256 amount);

    // Custom errors
    error InsufficientPayment();
    error TransactionAlreadyUsed();
    error UnauthorizedWithdrawal();
    error WithdrawalFailed();
    error NoWinnerSet();
    error InvalidAmount();

    constructor(uint256 _initialPrice) Ownable(msg.sender) {
        messagePrice = _initialPrice;
    }

    /**
     * @dev Set the winner address
     * @param _winner The address of the winner
     */
    function setWinner(address _winner) external onlyOwner {
        require(_winner != address(0), "Invalid winner address");
        winner = _winner;
        emit WinnerSet(_winner);
    }

    /**
     * @dev Pay for a message
     */
    function payForMessage() external payable whenNotPaused {
        // Check if payment meets minimum price
        if (msg.value < messagePrice) {
            revert InsufficientPayment();
        }

        // Generate unique hash for this transaction
        bytes32 txHash = keccak256(abi.encodePacked(msg.sender, block.timestamp, msg.value));

        // Check if transaction hash has been used
        if (usedTransactionHashes[txHash]) {
            revert TransactionAlreadyUsed();
        }

        // Mark transaction as used
        usedTransactionHashes[txHash] = true;

        // Increment user's message count
        userMessages[msg.sender]++;
        messagesProcessed++;

        // Emit event
        emit MessagePaid(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @dev Update the price per message
     * @param newPrice The new price in wei
     */
    function updatePrice(uint256 newPrice) external onlyOwner {
        messagePrice = newPrice;
        emit PriceUpdated(newPrice);
    }

    /**
     * @dev Get the number of messages a user has paid for
     * @param user The address to check
     */
    function getMessageCount(address user) external view returns (uint256) {
        return userMessages[user];
    }

    /**
     * @dev Check if a specific transaction hash has been used
     * @param txHash The hash to check
     */
    function isTransactionUsed(bytes32 txHash) external view returns (bool) {
        return usedTransactionHashes[txHash];
    }

    /**
     * @dev Withdraw funds according to role (winner or owner)
     */
    function withdraw() external {
        uint256 contractBalance = address(this).balance;
        if (contractBalance == 0) revert InvalidAmount();

        uint256 amount;
        if (msg.sender == winner) {
            if (winner == address(0)) revert NoWinnerSet();
            amount = (contractBalance * WINNER_SHARE) / 100;
            _processWithdrawal(payable(winner), amount);
            emit WinnerWithdrawal(winner, amount);
        } else if (msg.sender == owner()) {
            amount = (contractBalance * OWNER_SHARE) / 100;
            _processWithdrawal(payable(owner()), amount);
            emit OwnerWithdrawal(owner(), amount);
        } else {
            revert UnauthorizedWithdrawal();
        }
    }

    /**
     * @dev Internal function to process withdrawals
     */
    function _processWithdrawal(address payable to, uint256 amount) private {
        (bool success,) = to.call{value: amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        emit FundsWithdrawn(to, amount);
    }

    /**
     * @dev Get contract balance
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
