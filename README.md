# What

Provisions:

* 1 x Linux PC with nvida
* 1 x Linux PC without nvida
* 1 x Home Manager user 'innovation' on darwin\aarch64
* 1 x Home Manager user 'raf' on x86\_64

# Running

## Installation

```
# install hawking

nixos-install --flake .#hawking

# install feynman

nixos-install --flake .#feynman

```

## Home Manager Only

```
mkdir -p ~/.config/nixpkgs
cd !$
git clone git@github.com/fiq/nix-config
home-manager switch
```

