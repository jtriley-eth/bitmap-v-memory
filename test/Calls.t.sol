// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import {Calls, newCalls} from "src/Calls.sol";

contract CallsTest is Test {
    uint256 internal constant BEFORE_INITIALIZE_FLAG = 1 << 159;
    uint256 internal constant AFTER_INITIALIZE_FLAG = 1 << 158;
    uint256 internal constant BEFORE_MODIFY_POSITION_FLAG = 1 << 157;
    uint256 internal constant AFTER_MODIFY_POSITION_FLAG = 1 << 156;
    uint256 internal constant BEFORE_SWAP_FLAG = 1 << 155;
    uint256 internal constant AFTER_SWAP_FLAG = 1 << 154;
    uint256 internal constant BEFORE_DONATE_FLAG = 1 << 153;
    uint256 internal constant AFTER_DONATE_FLAG = 1 << 152;

    function testCallsBitmap() public {
        Calls calls = newCalls({
            beforeInitialize: true,
            afterInitialize: true,
            beforeModifyPosition: true,
            afterModifyPosition: true,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: true,
            afterDonate: true
        });

        assertTrue(calls.beforeInitialize());
        assertTrue(calls.afterInitialize());
        assertTrue(calls.beforeModifyPosition());
        assertTrue(calls.afterModifyPosition());
        assertTrue(calls.beforeSwap());
        assertTrue(calls.afterSwap());
        assertTrue(calls.beforeDonate());
        assertTrue(calls.afterDonate());
    }

    function testFuzzCallsBitmap(
        bool beforeInitialize,
        bool afterInitialize,
        bool beforeModifyPosition,
        bool afterModifyPosition,
        bool beforeSwap,
        bool afterSwap,
        bool beforeDonate,
        bool afterDonate
    ) public {
        Calls calls = newCalls(
            beforeInitialize,
            afterInitialize,
            beforeModifyPosition,
            afterModifyPosition,
            beforeSwap,
            afterSwap,
            beforeDonate,
            afterDonate
        );

        assertEq(calls.beforeInitialize(), beforeInitialize);
        assertEq(calls.afterInitialize(), afterInitialize);
        assertEq(calls.beforeModifyPosition(), beforeModifyPosition);
        assertEq(calls.afterModifyPosition(), afterModifyPosition);
        assertEq(calls.beforeSwap(), beforeSwap);
        assertEq(calls.afterSwap(), afterSwap);
        assertEq(calls.beforeDonate(), beforeDonate);
        assertEq(calls.afterDonate(), afterDonate);
    }

    function testFuzzValidateBitmap(
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
        Calls calls = newCalls(
            beforeInitialize,
            afterInitialize,
            beforeModifyPosition,
            afterModifyPosition,
            beforeSwap,
            afterSwap,
            beforeDonate,
            afterDonate
        );

        uint160 callsBitmap = calls.toUint160();
        uint160 hookBitmap = uint160(hookAddress);

        assertEq(
            calls.validateHookAddress(hookAddress),
            hookBitmap & callsBitmap == callsBitmap
        );
    }
}
