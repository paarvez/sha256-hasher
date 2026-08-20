# SHA-256 & Multi-Format Hasher for GTM

A lightweight, synchronous hashing variable template for **Google Tag Manager (Web Containers)**.

Runs 100% in GTM's native sandboxed JavaScript engine with **zero external script injection**, **zero network calls**, and **full CSP compliance**.

---

## Why This Exists

Standard GTM setups struggle with hashing in Web containers:
1. GTM's built-in `sha256` API is asynchronous and cannot be used in Variable templates (which require synchronous returns).
2. Third-party tags often inject external CDN scripts (`v9.js`, etc.) that get blocked by ad-blockers, tracking prevention, or strict Content Security Policies.

This template embeds a synchronous, pure-JS UTF-8 digest engine directly into the GTM Sandboxed Macro.

---

## Supported Formats

| Format | Output Example | Typical Use Case |
| :--- | :--- | :--- |
| **SHA-256 (HEX)** | `e3b0c44298fc1c149afbf4c8996fb924...` | Meta CAPI, Google Ads Enhanced Conversions, TikTok |
| **SHA-256 (Base64)** | `47DEQpj8HBSa+/TImW+5JCeuQeRkm5NM...` | Custom APIs / CDPs |
| **MD5 (HEX)** | `d41d8cd98f00b204e9800998ecf8427e` | CRM matching / Legacy pixels |
| **MD5 (Base64)** | `1B2M2Y8AsgTpgAmY7PhCfg==` | Base64-encoded MD5 digests |
| **Base64 (Raw)** | `dGVzdEBleGFtcGxlLmNvbQ==` | Payload obfuscation / basic encoding |
| **None** | Normalized raw string | Data cleaning without hashing |

---

## Built-in Normalization

* **Trim whitespace:** Strips leading and trailing spaces (enabled by default).
* **Lowercase conversion:** Standardizes case for emails and names (enabled by default).
* **Phone normalization:** Strips formatting characters (spaces, brackets, dashes), retaining leading `+` and digits.

---

## Installation

1. Download [`SHA-256 Hasher.tpl`](./SHA-256%20Hasher.tpl).
2. In Google Tag Manager, navigate to **Templates** → **Variable Templates** → **New**.
3. Click the top-right menu icon (**⋮**) → **Import**, select `SHA-256 Hasher.tpl`, and click **Save**.

---

## Usage

1. Create a new Variable in GTM.
2. Select **SHA-256 Hasher** as the variable type.
3. Choose your input variable (e.g. `{{DLV - email}}`), select the output format, and configure normalization.

---

## License

Apache 2.0
