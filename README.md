# Core Contracts

```
* = deployed contract

lib/
  |- Permissions
  |- Batch
  |- renderer/
      |- Renderer*
  |- module/
      |- FeeModule
  |- guard/
      |- OnePerAddress*
membership/
  |- Membership*
  |- MembershipFactory*
  |- modules/
      |- FixedETHPurchaseModule*
      |- FixedStablecoinPurchaseModule*
      |- PublicFreeMintModule*
badge/
  |- Badge*
  |- BadgeFactory*
```

View deployments in [deploys.json](./deploys.json).

# Presets 

These are a list of presets available from the membership factory

| description | label | fn | fn args |
| :--- | :--- | :--- | :--- |
| `Non-transferable` | `nt` | `guard(Operation, address)` | `Operation.TRANSFER`, `[MAX_ADDRESS]` |
|  `One token per address` | `opa` | `guard(Operation, address)` | `Operation.MINT`, `[OnePerAddress]` |
| `Gas-subsidized minting` | `gsm` | `permit(address, Operation)	` | `0xBb942519A1339992630b13c3252F04fCB09D4841`, `Operation.MINT` |
| `Offchain granting` | `grant` | `permit(address, Operation)	` | `0xBb942519A1339992630b13c3252F04fCB09D4841`, `Operation.GRANT` |
| `Free minting` | `free` | `permit(address, Operation)` | `[FreeMintModule]`, `Operation.MINT` |

There are also combination presets built from the above calls

| description | label |
| :--- | :--- |
| `Simple identity via non-transferability and one-per-address guards` | `nt+opa` |
|  `Simple identity with turnkey minting` | `nt+opa+turnkey` |
| `Simple identity with public, free minting` | `nt+opa_free` |


To deploy a membership using one of these existing presets, pass in the shorthand label from the table of presets in the `createFromPresets` function for the `presetDesc` arg