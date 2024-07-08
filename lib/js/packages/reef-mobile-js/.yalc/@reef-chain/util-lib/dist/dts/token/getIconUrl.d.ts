/**
 *  Returns icnUrl if exists, otherwise return sample icon based on calculated
 *  checksum from provided address. Returned sample icon is svg encoded to base64
 *  and prefixed with data string, so it can be used directly with <img /> tag.
 */
export declare const getIconUrl: (tokenAddress?: string) => string;
