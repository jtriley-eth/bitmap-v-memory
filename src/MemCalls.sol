// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

library Fees {
    uint24 public constant STATIC_FEE_MASK = 0x0FFFFF;
    uint24 public constant DYNAMIC_FEE_FLAG = 0x800000; // 1000
    uint24 public constant HOOK_SWAP_FEE_FLAG = 0x400000; // 0100
    uint24 public constant HOOK_WITHDRAW_FEE_FLAG = 0x200000; // 0010

    function isDynamicFee(uint24 self) internal pure returns (bool) {
        return self & DYNAMIC_FEE_FLAG != 0;
    }

    function hasHookSwapFee(uint24 self) internal pure returns (bool) {
        return self & HOOK_SWAP_FEE_FLAG != 0;
    }

    function hasHookWithdrawFee(uint24 self) internal pure returns (bool) {
        return self & HOOK_WITHDRAW_FEE_FLAG != 0;
    }
}

/// @notice V4 decides whether to invoke specific hooks by inspecting the leading bits of the address that
/// the hooks contract is deployed to.
/// For example, a hooks contract deployed to address: 0x9000000000000000000000000000000000000000
/// has leading bits '1001' which would cause the 'before initialize' and 'after swap' hooks to be used.
library Hooks {
    using Fees for uint24;

    uint256 internal constant BEFORE_INITIALIZE_FLAG = 1 << 159;
    uint256 internal constant AFTER_INITIALIZE_FLAG = 1 << 158;
    uint256 internal constant BEFORE_MODIFY_POSITION_FLAG = 1 << 157;
    uint256 internal constant AFTER_MODIFY_POSITION_FLAG = 1 << 156;
    uint256 internal constant BEFORE_SWAP_FLAG = 1 << 155;
    uint256 internal constant AFTER_SWAP_FLAG = 1 << 154;
    uint256 internal constant BEFORE_DONATE_FLAG = 1 << 153;
    uint256 internal constant AFTER_DONATE_FLAG = 1 << 152;

    struct Calls {
        bool beforeInitialize;
        bool afterInitialize;
        bool beforeModifyPosition;
        bool afterModifyPosition;
        bool beforeSwap;
        bool afterSwap;
        bool beforeDonate;
        bool afterDonate;
    }

    /// @notice Thrown if the address will not lead to the specified hook calls being called
    /// @param hooks The address of the hooks contract
    error HookAddressNotValid(address hooks);

    /// @notice Hook did not return its selector
    error InvalidHookResponse();

    /// @notice Utility function intended to be used in hook constructors to ensure
    /// the deployed hooks address causes the intended hooks to be called
    /// @param calls The hooks that are intended to be called
    /// @dev calls param is memory as the function will be called from constructors
    // function validateHookAddress(address self, Calls memory calls) internal pure {
    //     if (
    //         calls.beforeInitialize != shouldCallBeforeInitialize(self)
    //             || calls.afterInitialize != shouldCallAfterInitialize(self)
    //             || calls.beforeModifyPosition != shouldCallBeforeModifyPosition(self)
    //             || calls.afterModifyPosition != shouldCallAfterModifyPosition(self)
    //             || calls.beforeSwap != shouldCallBeforeSwap(self) || calls.afterSwap != shouldCallAfterSwap(self)
    //             || calls.beforeDonate != shouldCallBeforeDonate(self) || calls.afterDonate != shouldCallAfterDonate(self)
    //     ) {
    //         revert HookAddressNotValid(address(self));
    //     }
    // }

    // NOTE: modifying `validateHookAddress` to return bool instead of revert
    function validateHookAddress(address self, Calls memory calls) internal pure returns (bool) {
        return !(calls.beforeInitialize != shouldCallBeforeInitialize(self)
                || calls.afterInitialize != shouldCallAfterInitialize(self)
                || calls.beforeModifyPosition != shouldCallBeforeModifyPosition(self)
                || calls.afterModifyPosition != shouldCallAfterModifyPosition(self)
                || calls.beforeSwap != shouldCallBeforeSwap(self) || calls.afterSwap != shouldCallAfterSwap(self)
                || calls.beforeDonate != shouldCallBeforeDonate(self) || calls.afterDonate != shouldCallAfterDonate(self)
        );
    }

    function shouldCallBeforeInitialize(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & BEFORE_INITIALIZE_FLAG != 0;
    }

    function shouldCallAfterInitialize(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & AFTER_INITIALIZE_FLAG != 0;
    }

    function shouldCallBeforeModifyPosition(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & BEFORE_MODIFY_POSITION_FLAG != 0;
    }

    function shouldCallAfterModifyPosition(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & AFTER_MODIFY_POSITION_FLAG != 0;
    }

    function shouldCallBeforeSwap(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & BEFORE_SWAP_FLAG != 0;
    }

    function shouldCallAfterSwap(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & AFTER_SWAP_FLAG != 0;
    }

    function shouldCallBeforeDonate(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & BEFORE_DONATE_FLAG != 0;
    }

    function shouldCallAfterDonate(address self) internal pure returns (bool) {
        return uint256(uint160(address(self))) & AFTER_DONATE_FLAG != 0;
    }
}
