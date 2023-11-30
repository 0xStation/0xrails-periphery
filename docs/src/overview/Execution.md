# Execution and MultiCall

The 0xRails suite within GroupOS provides an execution template called `Execute`, which facilitates programmatic onchain actions. This opens the door to possibilities like creating [ERC4337-compliant smart accounts](../0xrails/src/cores/account/AccountRails.sol/abstract.AccountRails.md) and [ERC6551 tokenbound accounts](../0xrails/src/cores/ERC721Account/ERC721AccountRails.sol/contract.ERC721AccountRails.md).

### Security Considerations

Usage of `0xRails::Execute` should be approached with care, as arbitrary calls to onchain contracts in an environment as adversarial as the blockchain can lead to unintended or malicious end results. For this reason, the contract is marked abstract and forces an override of the `_checkCanExecuteCall()` check to ensure developers give consideration to access control when using the execution template.

```solidity
pragma solidity 0.8.19;

import {Execute} from "groupos/lib/0xrails/src/lib/Execute.sol";

contract Executioner is Execute {

    /// @dev Restrict calls via Execute to the `Operations.EXECUTE` permission
    function _checkCanExecuteCall() internal view override {
        _checkPermission(Operations.CALL, msg.sender);
    }
}
```

`Execute` also provides two hooks: `_beforeExecuteCall()` and `_afterExecuteCall()` which can be used to further configure important checks or perform external guard operations.

### DelegateCall

The `delegatecall` opcode is excluded from the Rails interface for simplicity and security. Enabling arbitrary external calls using the execution interface already introduces certain risks that developers must consider- we deemed enabling arbitrary delegatecalls to be more risky than beneficial. Should developers require usage of `delegatecall`, they are encouraged to fork Rails by overriding functions within Execute.

## MultiCall

Rails combines its execution template with [OpenZeppelin's MultiCall contract,](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/552cffde563e83043a6c3a35012b626a25eba775/contracts/utils/Multicall.sol) to perform numerous batched calls in a single atomic, gas-efficient transaction. The atomicity of the transaction is useful for sequential calls that rely on one another; it provides a way to revert previous calls in the cast that a later call in the sequence fails. 
