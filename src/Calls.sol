// SPDX-License-Identifier: GPL-2.0-or-later
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

type Calls is uint160;

using CallsLibrary for Calls global;

function newCalls(
    bool beforeInitialize,
    bool afterInitialize,
    bool beforeModifyPosition,
    bool afterModifyPosition,
    bool beforeSwap,
    bool afterSwap,
    bool beforeDonate,
    bool afterDonate
) pure returns (Calls calls) {
    /// @solidity memory-safe-assembly
    assembly {
        calls := shl(159, beforeInitialize)
        calls := or(calls, shl(158, afterInitialize))
        calls := or(calls, shl(157, beforeModifyPosition))
        calls := or(calls, shl(156, afterModifyPosition))
        calls := or(calls, shl(155, beforeSwap))
        calls := or(calls, shl(154, afterSwap))
        calls := or(calls, shl(153, beforeDonate))
        calls := or(calls, shl(152, afterDonate))
    }
}

library CallsLibrary {
    function beforeInitialize(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 159) != 0;
    }

    function afterInitialize(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 158) != 0;
    }

    function beforeModifyPosition(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 157) != 0;
    }

    function afterModifyPosition(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 156) != 0;
    }

    function beforeSwap(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 155) != 0;
    }

    function afterSwap(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 154) != 0;
    }

    function beforeDonate(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 153) != 0;
    }

    function afterDonate(Calls self) internal pure returns (bool) {
        return Calls.unwrap(self) & (1 << 152) != 0;
    }

    function toUint160(Calls self) internal pure returns (uint160) {
        return Calls.unwrap(self);
    }

    function validateHookAddress(Calls self, address hookAddress) internal pure returns (bool) {
        uint160 selfBitmap = self.toUint160();
        return uint160(hookAddress) & selfBitmap == selfBitmap;
    }
}
