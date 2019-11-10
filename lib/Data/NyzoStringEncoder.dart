import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrivateSeed.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/NyzoType.dart';
import 'package:nyzo_wallet/Data/TransactionMessage.dart';

class NyzoStringEncoder {
  static final List<String> characterLookup = ("0123456789" +
          "abcdefghijkmnopqrstuvwxyz" + // all except lowercase "L"
          "ABCDEFGHIJKLMNPQRSTUVWXYZ" + // all except uppercase "o"
          //"*+=_").toCharArray();       // old encoding, less URL-friendly
          "-.~_")
      .split(''); // see https://tools.ietf.org/html/rfc3986#section-2.3

  static final Map<String, int> _characterToValueMap = HashMap();
  NyzoStringEncoder() {
    for (int i = 0; i < characterLookup.length; i++) {
      _characterToValueMap[characterLookup[i]] = i;
    }
  }

  static final int headerLength = 4;

  static String encode(NyzoString stringObject) {
    // Get the prefix array from the type and the content array from the content object.
    Uint8List prefixBytes = stringObject.getType().getPrefixBytes();
    Uint8List contentBytes = stringObject.getBytes();

    // Determine the length of the expanded array with the header and the checksum. The header is the type-specific
    // prefix in characters followed by a single byte that indicates the length of the content array (four bytes
    // total). The checksum is a minimum of 4 bytes and a maximum of 6 bytes, widening the expanded array so that
    // its length is divisible by 3.
    int checksumLength = 4 + (3 - (contentBytes.length + 2) % 3) % 3;
    int expandedLength = headerLength + contentBytes.length + checksumLength;

    // Create the array and add the header and the content. The first three bytes turn into the user-readable
    // prefix in the encoded string. The next byte specifies the length of the content array, and it is immediately
    // followed by the content array.
    Uint8List expandedArray = Uint8List(expandedLength);
    int i;
    for (i = 0; i < prefixBytes.length; i++) {
      expandedArray[i] = prefixBytes[i];
    }
    expandedArray[i++] = contentBytes.length;

    for (int eachInt in contentBytes) {
      expandedArray[i++] = eachInt;
    }

    // Compute the checks um and add the appropriate number of bytes to the end of the array.
    Uint8List checksum =
        doubleSha256(expandedArray.sublist(0, 4 + contentBytes.length - 1));

    for (int eachInt in checksum) {
      expandedArray[i++] = eachInt;
    }

    // Build and return the encoded string from the expanded array.
    return encodedStringForByteArray(expandedArray);
  }

  static NyzoString decode(String encodedString) {
    NyzoString result;

    // Map characters from the old encoding to the new encoding. A few characters were changed to make Nyzo
    // strings more URL-friendly.
    encodedString = encodedString
        .replaceAll('*', '-')
        .replaceAll('+', '.')
        .replaceAll('=', '~');

    // Map characters that may be mistyped. Nyzo strings contain neither 'l' nor 'O'.
    encodedString = encodedString.replaceAll('l', '1').replaceAll('O', '0');

    // Get the type from the prefix.
    String type = NyzoStringType.forPrefix(encodedString.substring(0, 4));

    // If the type is valid, continue.
    if (type != null) {
      // Get the array representation of the encoded string.
      Uint8List expandedArray = byteArrayForEncodedString(encodedString);

      // Get the content length from the next byte and calculate the checksum length.
      int contentLength = expandedArray[3] & 0xff;
      int checksumLength = expandedArray.length - contentLength - 4;

      // Only continue if the checksum length is valid.
      if (checksumLength >= 4 && checksumLength <= 6) {
        // Calculate the checksum and compare it to the provided checksum. Only create the result array if
        // the checksums match.
        Uint8List calculatedChecksum =
            doubleSha256(expandedArray.sublist(0, headerLength + contentLength))
                .sublist(0, checksumLength);
        Uint8List providedChecksum = expandedArray.sublist(
            expandedArray.length - checksumLength, expandedArray.length);

        if (listEquals(calculatedChecksum, providedChecksum)) {
          // Get the content array. This is the encoded object with the prefix, length byte, and checksum
          // removed.
          Uint8List contentBytes = expandedArray.sublist(
              headerLength, expandedArray.length - checksumLength);

          // Make the object from the content array.
          switch (type) {
            case NyzoStringType.PrefilledData:
              result = NyzoStringPrefilledData(contentBytes.sublist(0, 32),
                  contentBytes.sublist(33, contentBytes.length));
              break;
            case NyzoStringType.PrivateSeed:
              result = NyzoStringPrivateSeed(contentBytes);
              break;
            case NyzoStringType.PublicIdentifier:
              result = NyzoStringPublicIdentifier(contentBytes);
              break;
          }
        }
        else{
          throw InvalisNyzoString();
        }
      }
      else{
          throw InvalisNyzoString();
        }
    }
    else{
          throw InvalisNyzoString();
        }

    return result;
  }

  static int getOrDefault(Map map, key, value) {
    if (map.containsKey(key)) return map[key];
    return value;
  }

  static Uint8List byteArrayForEncodedString(String encodedString) {
    Map<String, dynamic> characterToValueMap = Map();

    for (var i = 0; i < characterLookup.length; i++) {
      characterToValueMap[characterLookup[i]] = i;
    }

    var arrayLength = ((encodedString.length * 6 + 7) / 8).floor();

    var array = new Uint8List(arrayLength);
    for (var i = 0; i < arrayLength; i++) {
      var leftCharacter = encodedString.split('')[(i * 8 / 6).floor()];
      var rightCharacter = encodedString.split('')[(i * 8 / 6 + 1).floor()];

      var leftValue = characterToValueMap[leftCharacter];
      var rightValue = characterToValueMap[rightCharacter];
      var bitOffset = (i * 2) % 6;
      array[i] = ((((leftValue << 6) + rightValue) >> 4 - bitOffset) & 0xff);
    }

    return array;
  }

  static String encodedStringForByteArray(Uint8List array) {
    int index = 0;
    int bitOffset = 0;
    StringBuffer encodedString = StringBuffer();
    while (index < array.length) {
      // Get the current and next byte.
      int leftByte = array[index] & 0xff;
      int rightByte = index < array.length - 1 ? array[index + 1] & 0xff : 0;

      // Append the character for the next 6 bits in the array.
      int lookupIndex =
          (((leftByte << 8) + rightByte) >> (10 - bitOffset)) & 0x3f;
      encodedString.write(characterLookup[lookupIndex]);

      // Advance forward 6 bits.
      if (bitOffset == 0) {
        bitOffset = 6;
      } else {
        index++;
        bitOffset -= 2;
      }
    }

    return encodedString.toString();
  }
}

class InvalisNyzoString implements Exception { 
   String errMsg() => 'Invalid Nyzo String'; 
} 
