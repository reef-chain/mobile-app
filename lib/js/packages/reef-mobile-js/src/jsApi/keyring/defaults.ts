// Copyright 2017-2021 @polkadot/keyring authors & contributors
// SPDX-License-Identifier: Apache-2.0

// default substrate dev phrase
export const DEV_PHRASE = 'bottom drive obey lake curtain smoke basket hold race lonely fit walk';

// seed from the above phrase
export const DEV_SEED = '0xfac7959dbfe72f052e5a0c3c8d6530f202b02fd8f9f5ca3580ec8deb7797479e';


export const PKCS8_DIVIDER = new Uint8Array([161, 35, 3, 33, 0]);
export const PKCS8_HEADER = new Uint8Array([48, 83, 2, 1, 1, 48, 5, 6, 3, 43, 101, 112, 4, 34, 4, 32]);
export const PUB_LENGTH = 32;
export const SALT_LENGTH = 32;
export const SEC_LENGTH = 64;
export const SEED_LENGTH = 32;