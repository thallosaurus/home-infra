# Tor Proxy
I have installed a Tor Proxy in the Network which allows anyone to connect to the hidden dark net without additional software

## Configure Firefox
### Configure Proxy
Open the Firefox Settings, search for Proxy and click on `Network Settings - Settings...`. Select `Manual proxy configuration` and enter the following for the `SOCKS Host`

|IP|Port|
|-|-|
|10.0.0.5|9050|

Also check `Proxy DNS when using SOCKS v5`. Click on `OK`.

### Allow Tor Domains
Open the Page `about:config` in Firefox and click `Accept the Risk and Continue`
- Search for `network.dns.blockDotOnion` and set the value to `false`
- Search for `dom.securecontext.allowlist_onions` and set the value to `true`
- Search for `security.enterprise_roots.enable`, set it to `true`

Open the Page `https://check.torproject.org/` and it should tell you this Browser is configured to use Tor. Congrats

### Recommended Plugins
- [NoScript](https://noscript.net)
- [FoxyProxy Standart](https://addons.mozilla.org/de/firefox/addon/foxyproxy-standard/)