// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import {Hooks} from "src/MemCalls.sol";

contract CallsTest is Test {
    function testCallsMemory() public {
        Hooks.Calls memory calls = Hooks.Calls({
            beforeInitialize: true,
            afterInitialize: true,
            beforeModifyPosition: true,
            afterModifyPosition: true,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: true,
            afterDonate: true
        });

        assertTrue(calls.beforeInitialize);
        assertTrue(calls.afterInitialize);
        assertTrue(calls.beforeModifyPosition);
        assertTrue(calls.afterModifyPosition);
        assertTrue(calls.beforeSwap);
        assertTrue(calls.afterSwap);
        assertTrue(calls.beforeDonate);
        assertTrue(calls.afterDonate);
    }

    function testFuzzCallsMemory(
        bool beforeInitialize,
        bool afterInitialize,
        bool beforeModifyPosition,
        bool afterModifyPosition,
        bool beforeSwap,
        bool afterSwap,
        bool beforeDonate,
        bool afterDonate
    ) public {
        Hooks.Calls memory calls = Hooks.Calls({
            beforeInitialize: beforeInitialize,
            afterInitialize: afterInitialize,
            beforeModifyPosition: beforeModifyPosition,
            afterModifyPosition: afterModifyPosition,
            beforeSwap: beforeSwap,
            afterSwap: afterSwap,
            beforeDonate: beforeDonate,
            afterDonate: afterDonate
        });

        assertEq(calls.beforeInitialize, beforeInitialize);
        assertEq(calls.afterInitialize, afterInitialize);
        assertEq(calls.beforeModifyPosition, beforeModifyPosition);
        assertEq(calls.afterModifyPosition, afterModifyPosition);
        assertEq(calls.beforeSwap, beforeSwap);
        assertEq(calls.afterSwap, afterSwap);
        assertEq(calls.beforeDonate, beforeDonate);
        assertEq(calls.afterDonate, afterDonate);
    }

    function testFuzzValidateMemory(
        address hookAddress,
        bool beforeInitialize,
        bool afterInitialize,
        bool beforeModifyPosition,
        bool afterModifyPosition,
        bool beforeSwap,
        bool afterSwap,
        bool beforeDonate,
        bool afterDonate
    ) public {
        Hooks.Calls memory calls = Hooks.Calls(
            beforeInitialize,
            afterInitialize,
            beforeModifyPosition,
            afterModifyPosition,
            beforeSwap,
            afterSwap,
            beforeDonate,
            afterDonate
        );

        uint160 hookBitmap = uint160(hookAddress);

        assertEq(
            Hooks.validateHookAddress(hookAddress, calls),
            (calls.beforeInitialize == (hookBitmap & Hooks.BEFORE_INITIALIZE_FLAG != 0))
                && (calls.afterInitialize == (hookBitmap & Hooks.AFTER_INITIALIZE_FLAG != 0))
                && (calls.beforeModifyPosition == (hookBitmap & Hooks.BEFORE_MODIFY_POSITION_FLAG != 0))
                && (calls.afterModifyPosition == (hookBitmap & Hooks.AFTER_MODIFY_POSITION_FLAG != 0))
                && (calls.beforeSwap == (hookBitmap & Hooks.BEFORE_SWAP_FLAG != 0))
                && (calls.afterSwap == (hookBitmap & Hooks.AFTER_SWAP_FLAG != 0))
                && (calls.beforeDonate == (hookBitmap & Hooks.BEFORE_DONATE_FLAG != 0))
                && (calls.afterDonate == (hookBitmap & Hooks.AFTER_DONATE_FLAG != 0))
        );
    }
}
