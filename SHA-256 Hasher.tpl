___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "sha256_hasher_sync",
  "version": 1,
  "securityGroups": [],
  "displayName": "SHA-256 Hasher",
  "description": "Converts any text or variable value into a SHA-256 hash.",
  "categories": [
    "UTILITY",
    "PRIVACY"
  ],
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "input",
    "displayName": "Value to Hash",
    "simpleValueType": true,
    "help": "Enter a value or select a GTM variable (e.g. {{DLV - email}}). Input is lowercased and trimmed before hashing."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var makeString = require('makeString');
var encodeUriComponent = require('encodeUriComponent');
var value = data.input;
if (value === undefined || value === null || value === '') {
  return '';
}
var s = makeString(value).toLowerCase().trim();
if (s === '') {
  return '';
}

var HEX = '0123456789abcdef';
var UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var LOWER = 'abcdefghijklmnopqrstuvwxyz';
var DIGITS = '0123456789';
var encoded = encodeUriComponent(s);

var b = [];
var j = 0;
var ch;
var idx;
var hv;
while (j < encoded.length) {
  ch = encoded.charAt(j);
  if (ch === '%') {
    hv = HEX.indexOf(encoded.charAt(j + 1));
    var bhi = hv * 16;
    hv = HEX.indexOf(encoded.charAt(j + 2));
    b.push(bhi + hv);
    j = j + 3;
  } else {
    idx = UPPER.indexOf(ch);
    if (idx >= 0) {
      b.push(idx + 65);
    } else {
      idx = LOWER.indexOf(ch);
      if (idx >= 0) {
        b.push(idx + 97);
      } else {
        idx = DIGITS.indexOf(ch);
        if (idx >= 0) {
          b.push(idx + 48);
        } else if (ch === '-') {
          b.push(45);
        } else if (ch === '_') {
          b.push(95);
        } else if (ch === '.') {
          b.push(46);
        } else if (ch === '!') {
          b.push(33);
        } else if (ch === '~') {
          b.push(126);
        } else if (ch === '*') {
          b.push(42);
        } else if (ch === "'") {
          b.push(39);
        } else if (ch === '(') {
          b.push(40);
        } else if (ch === ')') {
          b.push(41);
        } else {
          b.push(63);
        }
      }
    }
    j = j + 1;
  }
}

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
var i;

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
    var ch = (ve & vf) ^ ((ve ^ -1) & vg);
    var temp1 = (vh + S1 + ch + K[t] + w[t]) | 0;
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

var result = '';
var hv2;
for (i = 0; i < 8; i = i + 1) {
  hv2 = [H0, H1, H2, H3, H4, H5, H6, H7][i];
  result = result + HEX.charAt((hv2 >>> 28) & 15);
  result = result + HEX.charAt((hv2 >>> 24) & 15);
  result = result + HEX.charAt((hv2 >>> 20) & 15);
  result = result + HEX.charAt((hv2 >>> 16) & 15);
  result = result + HEX.charAt((hv2 >>> 12) & 15);
  result = result + HEX.charAt((hv2 >>> 8) & 15);
  result = result + HEX.charAt((hv2 >>> 4) & 15);
  result = result + HEX.charAt(hv2 & 15);
}
return result;


___TESTS___

scenarios: []


___NOTES___

Created on 24/04/2026, 20:48:18


