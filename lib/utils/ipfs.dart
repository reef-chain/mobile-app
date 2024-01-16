class IpfsUtils {
  static String getIpfsUrl(String hash) {
    return "https://reef.infura-ipfs.io/ipfs/$hash";
  }

  static String resolveIpfsHash(String input) {
    if (input.startsWith("ipfs")) return getIpfsUrl(input.split("/").last);
    return input;
  }
}
