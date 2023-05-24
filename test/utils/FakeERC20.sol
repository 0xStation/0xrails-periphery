import { ERC20 } from "openzeppelin-contracts/token/ERC20/ERC20.sol";
contract FakeERC20 is ERC20 {
    uint8 private _decimals;

    constructor(uint8 decimals_) ERC20("FAKE", "FAKE") {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}