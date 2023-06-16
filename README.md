# Bitmap vs Memory

## Overview

This repo contains gas tests against Uniswap v4's `Calls` struct consisting of booleans using
bitmaps.

Due to solc's rules around memory structs, `Calls memory` occupies eight slots, or 256 _bytes_  of
memory for each instance.

The [Calls](./src/Calls.sol) library contains a custom `Calls` type that is instead a bitmap over
`uint160`, allowing for the data to stay on the stack and out of memory, easy access to any bit by
simple bit ops, and address validation to be reduced to a single mask operation.

The API for the `Calls` bitmap follows that of the struct but with globally applied methods instead
of simple field accesses. However, following the compiler configuration in the
[Foundry Config](./foundry.toml), the optimizer _should_ inline the functions, given their
simplicity. (This needs to be verified, the optimizer is finnicky).

## Findings

Initial findings consist of the following and can be found in the [gas snapshot](./.gas-snapshot).

| memory | bitmap | diff | type                           |
| ------ | ------ | ---- | ------------------------------ |
| 792    | 666    | 126  | basic check fields (total)     |
| 1743   | 1729   | 14   | fuzz check fields (mean)       |
| 1743   | 1729   | 14   | fuzz check fields (median)     |
| 1945   | 1248   | 697  | fuzz validate address (mean)   |
| 1842   | 1248   | 594  | fuzz validate address (median) |
