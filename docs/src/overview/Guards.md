# Guards

Guards enforce constraints on an operation that apply to all entry points. When we parallelize the ability to mutate state with our Access and Modules layers, sometimes we need to reconstrain behavior.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/ecfe18ab-65d7-4341-9993-e5b5708f84b4.png">

For example, an identity token may mint when purchased through a Module, granted by an administrator, or claimed as a reward, but should always enforce that one address can only own one identity token, preventing a mint if the account already holds a balance.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/c4274523-7469-40dc-a2be-88e727554688.png">

## Using Guards

Guards are externalized contracts, attached to specific operations, and can be swapped out modularly just like Modules. To utilize a Guard, an operation needs to expose one or two “hooks” that allow the insertion of an external call to the Guard before and/or after executing. 

In our earlier example, these hooks would run before and after a token transfer took place, allowing a [OnePerAddressGuard](../groupos/src/membership/guards/OnePerAddressGuard.sol/contract.OnePerAddressGuard.md) to enforce the condition that the recipient of a token does not own more than 1 unit.

## Single Guard Per Operation

Unlike Modules, the base implementation only enables one Guard per operation. This constraint is created because Guards need to be accessed by a specific operation, creating a mapping storage pattern from operations (type bytes8) to Guards (type address). Given the flexibility of the abstraction and externalizing logic, it is still possible to create a Guard that logically composes many Guards, enabling seamless no-code workflows like checking constraint boxes from a list of mutually independent options.