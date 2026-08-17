# Clash Verge Rev

Home Manager generates and deploys the Tailnet Script profile to:

```text
~/Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/profiles/Script.js
```

The generated file is declaration-managed and is overwritten by `switch-home`.
Clash Verge profile metadata, subscriptions, credentials, and generated runtime
state remain application-owned.

After activating Home Manager, select or enable `Script.js` in Clash Verge Rev.
The Tailscale auth key is intentionally not stored in this repository or in the
Nix-generated script; complete authentication through the application's normal
interactive flow.
