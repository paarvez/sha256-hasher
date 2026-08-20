___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  type: MACRO,
  id: sha256_hasher_sync,
  version: 1,
  securityGroups: [],
  displayName: SHA-256 Hasher,
  description: Converts any text or variable value into a SHA-256, MD5, or Base64 hash with formatting and normalization options.,
  categories: [
    UTILITY,
    PRIVACY
  ],
  containerContexts: [
    WEB
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    type: TEXT,
    name: input,
    displayName: Value to Hash,
    simpleValueType: true,
    help: Enter a value or select a GTM variable (e.g. {{DLV - email}}).,
    valueValidators: [
      {
        type: NON_EMPTY
      }
    ]
  },
  {
    type: SELECT,
    name: hash_format,
    displayName: Hash / Output Format,
    selectItems: [
      {
        value: sha256_hex,
        displayValue: SHA-256 (HEX - standard)
      },
      {
        value: sha256_base64,
        displayValue: SHA-256 (Base64)
      },
      {
        value: md5_hex,
        displayValue: MD5 (HEX)
      },
      {
        value: md5_base64,
        displayValue: MD5 (Base64)
      },
      {
        value: base64,
        displayValue: Base64 (Raw encoding)
      },
      {
        value: none,
        displayValue: None (Normalization only)
      }
    ],
    defaultValue: sha256_hex,
    simpleValueType: true
  },
  {
    type: GROUP,
    name: normalization_group,
    displayName: Normalization Options,
    subParams: [
      {
        type: CHECKBOX,
        name: trim_spaces,
        checkboxText: Trim leading & trailing whitespace,
        defaultValue: true,
        simpleValueType: true
      },
      {
        type: CHECKBOX,
        name: to_lowercase,
        checkboxText: Convert to lowercase,
        defaultValue: true,
        simpleValueType: true
      },
      {
        type: CHECKBOX,
        name: phone_format,
        checkboxText: Format as phone number (strip special characters),
        defaultValue: false,
        simpleValueType: true
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var makeString = require('makeString');
var encodeUriComponent = require('encodeUriComponent');
var toBase64 = require('toBase64');

var rawValue = data.input;
if (rawValue === undefined || rawValue === null || rawValue === '') {
  return '';
}

var s = makeString(rawValue);

if (data.trim_spaces !== false) {
  s = s.trim();
}
if (data.to_lowercase !== false) {
  s = s.toLowerCase();
}
if (data.phone_format === true) {
  var cleaned = '';
  for (var k = 0; k < s.length; k++) {
    var c = s.charAt(k);
    if ((c >= '0' && c <= '9') || (k === 0 && c === '+')) {
      cleaned += c;
    }
  }
  s = cleaned;
}

if (s === '') {
  return '';
}

var format = data.hash_format || 'sha256_hex';
if (format === 'none') {
  return s;
}
if (format === 'base64') {
  return toBase64(s);
}

var HEX = '0123456789abcdef';
var UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var LOWER = 'abcdefghijklmnopqrstuvwxyz';
var DIGITS = '0123456789';
var encoded = encodeUriComponent(s);

var bytes = [];
var j = 0;
while (j < encoded.length) {
  var ch = encoded.charAt(j);
  if (ch === '%') {
    var hv = HEX.indexOf(encoded.charAt(j + 1)) * 16 + HEX.indexOf(encoded.charAt(j + 2));
    bytes.push(hv);
    j += 3;
  } else {
    var idx = UPPER.indexOf(ch);
    if (idx >= 0) {
      bytes.push(idx + 65);
    } else {
      idx = LOWER.indexOf(ch);
      if (idx >= 0) {
        bytes.push(idx + 97);
      } else {
        idx = DIGITS.indexOf(ch);
        if (idx >= 0) {
          bytes.push(idx + 48);
        } else if (ch === '-') {
          bytes.push(45);
        } else if (ch === '_') {
          bytes.push(95);
        } else if (ch === '.') {
          bytes.push(46);
        } else if (ch === '!') {
          bytes.push(33);
        } else if (ch === '~') {
          bytes.push(126);
        } else if (ch === '*') {
          bytes.push(42);
        } else if (ch === ') {
          bytes.push(39);
        } else if (ch === '(') {
          bytes.push(40);
        } else if (ch === ')') {
          bytes.push(41);
        } else {
          bytes.push(63);
        }
      }
    }
    j += 1;
  }
}

function bytesToHex(arr) {
  var res = '';
  for (var i = 0; i < arr.length; i++) {
    var b = arr[i];
    res += HEX.charAt((b >>> 4) & 15) + HEX.charAt(b & 15);
  }
  return res;
}

function bytesToBase64(arr) {
  var B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  var res = '';
  var i = 0;
  for (i = 0; i + 2 < arr.length; i += 3) {
    var n = (arr[i] << 16) | (arr[i + 1] << 8) | arr[i + 2];
    res += B64.charAt((n >>> 18) & 63);
    res += B64.charAt((n >>> 12) & 63);
    res += B64.charAt((n >>> 6) & 63);
    res += B64.charAt(n & 63);
  }
  if (i < arr.length) {
    var rem = arr.length - i;
    var n2 = arr[i] << 16;
    if (rem === 2) {
      n2 |= arr[i + 1] << 8;
    }
    res += B64.charAt((n2 >>> 18) & 63);
    res += B64.charAt((n2 >>> 12) & 63);
    if (rem === 2) {
      res += B64.charAt((n2 >>> 6) & 63) + '=';
    } else {
      res += '==';
    }
  }
  return res;
}

function computeSHA256(inputBytes) {
  var b = inputBytes.slice();
  var l = b.length * 8;
  b.push(128);
  while (b.length % 64 !== 56) {
    b.push(0);
  }
  b.push(0);
  b.push(0);
  b.push(0);
  b.push(0);
  b.push((l >>> 24) & 255);
  b.push((l >>> 16) & 255);
  b.push((l >>> 8) & 255);
  b.push(l & 255);

  var H0 = 1779033703;
  var H1 = 3144134277;
  var H2 = 1013904242;
  var H3 = 2773480762;
  var H4 = 1359893119;
  var H5 = 2600822924;
  var H6 = 528734635;
  var H7 = 1541459225;

  var K = [1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298];

  var w = [];
  var p;
  var t;

  for (p = 0; p < b.length; p = p + 64) {
    var va = H0;
    var vb = H1;
    var vc = H2;
    var vd = H3;
    var ve = H4;
    var vf = H5;
    var vg = H6;
    var vh = H7;

    for (t = 0; t < 16; t = t + 1) {
      w[t] = ((b[p + t * 4] << 24) | (b[p + t * 4 + 1] << 16) | (b[p + t * 4 + 2] << 8) | b[p + t * 4 + 3]) | 0;
    }

    for (t = 16; t < 64; t = t + 1) {
      var s0x = w[t - 2];
      var r17 = (s0x >>> 17) | (s0x << 15);
      var r19 = (s0x >>> 19) | (s0x << 13);
      var s0 = r17 ^ r19 ^ (s0x >>> 10);
      var s1x = w[t - 15];
      var r7 = (s1x >>> 7) | (s1x << 25);
      var r18 = (s1x >>> 18) | (s1x << 14);
      var s1 = r7 ^ r18 ^ (s1x >>> 3);
      w[t] = (s0 + w[t - 7] + s1 + w[t - 16]) | 0;
    }

    for (t = 0; t < 64; t = t + 1) {
      var S1a = (ve >>> 6) | (ve << 26);
      var S1b = (ve >>> 11) | (ve << 21);
      var S1c = (ve >>> 25) | (ve << 7);
      var S1 = S1a ^ S1b ^ S1c;
      var ch1 = (ve & vf) ^ ((ve ^ -1) & vg);
      var temp1 = (vh + S1 + ch1 + K[t] + w[t]) | 0;
      var S0a = (va >>> 2) | (va << 30);
      var S0b = (va >>> 13) | (va << 19);
      var S0c = (va >>> 22) | (va << 10);
      var S0 = S0a ^ S0b ^ S0c;
      var maj = (va & vb) ^ (va & vc) ^ (vb & vc);
      var temp2 = (S0 + maj) | 0;
      vh = vg;
      vg = vf;
      vf = ve;
      ve = (vd + temp1) | 0;
      vd = vc;
      vc = vb;
      vb = va;
      va = (temp1 + temp2) | 0;
    }

    H0 = (H0 + va) | 0;
    H1 = (H1 + vb) | 0;
    H2 = (H2 + vc) | 0;
    H3 = (H3 + vd) | 0;
    H4 = (H4 + ve) | 0;
    H5 = (H5 + vf) | 0;
    H6 = (H6 + vg) | 0;
    H7 = (H7 + vh) | 0;
  }

  var rawBytes = [];
  var hArr = [H0, H1, H2, H3, H4, H5, H6, H7];
  for (var i = 0; i < 8; i = i + 1) {
    var v = hArr[i];
    rawBytes.push((v >>> 24) & 255);
    rawBytes.push((v >>> 16) & 255);
    rawBytes.push((v >>> 8) & 255);
    rawBytes.push(v & 255);
  }
  return rawBytes;
}

function computeMD5(inputBytes) {
  var b = inputBytes.slice();
  var l = b.length * 8;
  b.push(128);
  while (b.length % 64 !== 56) {
    b.push(0);
  }
  b.push(l & 255);
  b.push((l >>> 8) & 255);
  b.push((l >>> 16) & 255);
  b.push((l >>> 24) & 255);
  b.push(0);
  b.push(0);
  b.push(0);
  b.push(0);

  var a = 1732584193;
  var b0 = -271733879;
  var c = -1732584194;
  var d = 271733878;
  var S = [7,12,17,22, 5,9,14,20, 4,11,16,23, 6,10,15,21];
  var T = [
    3614090360,3905402710,606105819,3250441966,4118548399,1200080426,2821735955,4249261313,
    1770035416,2336552879,4294925233,2304563134,1804603682,4254626195,2792965006,1236535329,
    4129170786,3225465664,643717713,3921069994,3593408605,38016083,3634488961,3889429448,
    568446438,3275163606,4107603335,1163531501,2850285829,4243563512,1735328473,2368359562,
    4294588738,2272392833,1839030562,4259657740,2763975236,1272893353,4139469664,3200236656,
    681279174,3936430074,3572445317,76029189,3654602809,3873151461,530742520,3299628645,
    4096336452,1126891415,2878612391,4237533241,1700485571,2399980690,4293915773,2240044497,
    1873313359,4264355552,2734768916,1309151649,4149444226,3174756917,718787259,3951481745
  ];

  for (var p = 0; p < b.length; p = p + 64) {
    var M = [];
    for (var i = 0; i < 16; i = i + 1) {
      M[i] = b[p + i * 4] | (b[p + i * 4 + 1] << 8) | (b[p + i * 4 + 2] << 16) | (b[p + i * 4 + 3] << 24);
    }
    var A = a;
    var B = b0;
    var C = c;
    var D = d;
    for (var j0 = 0; j0 < 64; j0 = j0 + 1) {
      var F;
      var g;
      if (j0 < 16) {
        F = (B & C) | ((~B) & D);
        g = j0;
      } else if (j0 < 32) {
        F = (D & B) | ((~D) & C);
        g = (5 * j0 + 1) % 16;
      } else if (j0 < 48) {
        F = B ^ C ^ D;
        g = (3 * j0 + 5) % 16;
      } else {
        F = C ^ (B | (~D));
        g = (7 * j0) % 16;
      }
      var sRot = S[((j0 >>> 4) * 4) + (j0 % 4)];
      var temp = (A + F + T[j0] + M[g]) | 0;
      var rot = (temp << sRot) | (temp >>> (32 - sRot));
      A = D;
      D = C;
      C = B;
      B = (B + rot) | 0;
    }
    a = (a + A) | 0;
    b0 = (b0 + B) | 0;
    c = (c + C) | 0;
    d = (d + D) | 0;
  }

  var rawHashBytes = [];
  var arr = [a, b0, c, d];
  for (var k = 0; k < 4; k = k + 1) {
    var val = arr[k];
    rawHashBytes.push(val & 255);
    rawHashBytes.push((val >>> 8) & 255);
    rawHashBytes.push((val >>> 16) & 255);
    rawHashBytes.push((val >>> 24) & 255);
  }
  return rawHashBytes;
}

if (format === 'sha256_hex') {
  return bytesToHex(computeSHA256(bytes));
}
if (format === 'sha256_base64') {
  return bytesToBase64(computeSHA256(bytes));
}
if (format === 'md5_hex') {
  return bytesToHex(computeMD5(bytes));
}
if (format === 'md5_base64') {
  return bytesToBase64(computeMD5(bytes));
}

return '';


___TESTS___

scenarios: []


___NOTES___

Updated with multi-format hashing (SHA-256 Hex/Base64, MD5 Hex/Base64, Base64, Normalization)
