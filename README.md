# ScopeBuddy

A manager script to make gamescope easier to use on the desktop (or if you use it in desktop mode and gamemode)

Originally made for [Bazzite](https://bazzite.gg), released here so more projects can make use of it! ❤️

Turn this

![gamescope Launch Options](/repo_content/launch_options_gamescope.png?raw=true "gamescope Launch Options")

Into this (you can also replace `scopebuddy` with `scb` if you set that up)

![scopebuddy Launch Options](/repo_content/launch_options_scopebuddy.png?raw=true "scopebuddy Launch Options")

Features:

* Fixes the Steam Overlay when used in nested/desktop mode
* Fixes SteamInput when used in nested/desktop mode
* Does not launch gamescope when it detects being started inside gamemode/gamescope-session
* Enables you to define global defaults arguments for gamescope in desktop mode
* Enables you to define per-game arguments for gamescope
* Enables you to define global and per-game ENV variables
* Optionally use scb just for ENV var management
* Automatically infer display output args (output width, height, refresh rate, HDR, or VRR flags) from primary display (KDE Plasma and GNOME)

## Documentation and usage

Look at <https://docs.bazzite.gg/Advanced/scopebuddy/>

## Auto-Detection Features (`SCB_AUTO_*`)

ScopeBuddy can automatically detect your display settings and configure gamescope accordingly:

* **SCB_AUTO_RES=1**: Automatically detect and set display resolution (`-W` and `-H`)
* **SCB_AUTO_HDR=1**: Automatically enable HDR if your display has HDR enabled
* **SCB_AUTO_VRR=1**: Automatically enable adaptive sync if VRR is active on your display
* **SCB_AUTO_REFRESH=1**: Automatically set an explicit refresh rate (`-r`) to your current monitor refresh rate. **NOTE: this has known limitations, and often doesn't work if `--adaptive-sync` or `SCB_AUTO_VRR` is set.**
* **SCB_AUTO_FRAME_LIMIT=1**: Automatically set a gamescope's framerate limiter (`--framerate-limit`) to your current monitor refresh rate. **NOTE: this has known limitations, and often doesn't work if `--adaptive-sync` or `SCB_AUTO_VRR` is set.**

### Desktop Environment Support

* **KDE Plasma**: Uses `kscreen-doctor` (requires `jq`)
* **GNOME**: Uses either `gdctl` (requires `jq` and upstream version with `--format=json` support) or `gnome-randr` as fallback
* **Wlroots Compositor**: Uses "wlr-randr" (requires `jq`)

### Usage Examples

**In Steam launch options:**

```bash
SCB_AUTO_RES=1 SCB_AUTO_HDR=1 SCB_AUTO_VRR=1 scopebuddy -- %command%
```

**In config file (~/.config/scopebuddy/scb.conf):**

```bash
# Enable auto-detection for resolution, HDR, and VRR
SCB_AUTO_RES=1
SCB_AUTO_HDR=1
SCB_AUTO_VRR=1
SCB_AUTO_REFRESH=1
SCB_AUTO_FRAME_LIMIT=1
```

### GNOME Support

ScopeBuddy supports two methods for GNOME display detection:

#### Option 1: gdctl (Preferred - may require manual steps)

For GNOME users with an upstream version of `gdctl` that supports `--format=json`. ScopeBuddy will automatically test if your `gdctl` version supports this.

You can check if you have a version that supports this by running

`gdctl show --format=json` in your terminal. If you see output about your display, your version is supported.

If you see

```
usage: gdctl [-h] COMMAND ...
gdctl: error: unrecognized arguments: --format=json
```

Then your distribution's version doesn't support JSON output yet. You can either proceed to option 2 (gnome-randr) or download the upstream version of gdctl from [this merge request](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/4708):

> **Note:** The GNOME GitLab may require authentication to download files directly. If you encounter a permissions error, log in to your GitLab account in your browser, navigate to the merge request, and download the `gdctl` file manually. Save it as `~/.local/bin/gdctl-mr4708` and make it executable:

```bash
chmod +x ~/.local/bin/gdctl-mr4708
```

Then use it with the `GDCTL_COMMAND` variable:

**In Steam launch options:**

```bash
GDCTL_COMMAND=$HOME/.local/bin/gdctl-mr4708 SCB_AUTO_RES=1 SCB_AUTO_HDR=1 SCB_AUTO_VRR=1 scopebuddy -- %command%
```

**In config file:**

```bash
export GDCTL_COMMAND="$HOME/.local/bin/gdctl-mr4708"
SCB_AUTO_RES=1
SCB_AUTO_HDR=1
SCB_AUTO_VRR=1
```

#### Option 2: gnome-randr (Automatic Fallback)

If `gdctl` is not available or doesn't support `--format=json`, ScopeBuddy will automatically fall back to using [`gnome-randr`](https://github.com/maxwellainatchi/gnome-randr-rust).

gnome-randr is shipped by default with Bazzite's GNOME-based images, and should be available through package managers on most other distros.

You can also specify a custom `gnome-randr` path:

**In config file:**

```bash
export GNOME_RANDR_COMMAND="$HOME/.local/bin/gnome-randr"
SCB_AUTO_RES=1
SCB_AUTO_HDR=1
SCB_AUTO_VRR=1
```

### Wlroots Compositor Support

Wlroots compositors do not have any concept of a primary monitor, so the monitor must be specified with gamescope's `-O` or `--prefer-output` flag. See [Multi-Monitor Support](#multi-monitor-support) for more info.

### Multi-Monitor Support

If you're using multiple monitors and want to target a specific display, use gamescope's `-O` or `--prefer-output` flag:

```bash
SCB_AUTO_RES=1 scopebuddy -O DP-3 -- %command%
```

### Auto HDR for games launched without Gamescope (experimental)

Scopebuddy can be configured to bypass gamescope entirely using the `SCB_NOSCOPE=1` variable.

Most of the `SCB_AUTO_*` variables are ignored in this mode. However, HDR can be used in non-gamescope contexts by using any fork/variant of Proton version 10+ with experimental support for wayland enabled.

One of the following Proton versions is required for this feature to work:

* Proton-GE 10+
* Proton-EM 10+
* Proton CachyOS 10+
* Proton-TKG 10+

These can either be set per-game in the "Properties -> Compatibility" tab, or Globally in "Steam Settings -> Compatibility"

In scb.conf:

```
SCB_AUTO_HDR=1
SCB_NOSCOPE=1
```

Alternatively, `SCB_NOSCOPE` can be left out of scb.conf and set in either a game-specific scb.conf file or directly launch options: `SCB_NOSCOPE=1 scb -- %command%`.

## Installation

### Requirements

* bash
* [gamescope](https://github.com/ValveSoftware/gamescope)
* perl

Optional for `$SCB_AUTO_RES`/`$SCB_AUTO_HDR`/`$SCB_AUTO_VRR`:

* **KDE Plasma**: `kscreen-doctor` (usually pre-installed) and `jq` (installed by default on Bazzite)
* **GNOME**: Either `gdctl` with `--format=json` support (requires `jq`) OR `gnome-randr` (see GNOME Support section above)
* **Wlroots Compositor**: Uses "wlr-randr" (requires `jq`)

#### Using curl

```bash
sudo curl -Lo /usr/local/bin/scopebuddy https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
sudo chmod +x /usr/local/bin/scopebuddy
```

#### Using wget

```bash
sudo wget -O /usr/local/bin/scopebuddy https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
sudo chmod +x /usr/local/bin/scopebuddy
```

#### Make `scb` symlink because we love short commands

NOTE: You only need to do this once

```bash
sudo ln -s scopebuddy /usr/local/bin/scb
```

#### Specific version

* Download the versioned release from github releases
* Extract the script
* Move to /usr/local/bin or /usr/bin
* make scb symlink

### NixOS

#### Using flakes

Home Manager (flake-based), add an input:

```bash
inputs.scopebuddy.url = "github:HikariKnight/ScopeBuddy";
```

Then add the package:

```bash
home.packages = [
  inputs.scopebuddy.packages.${pkgs.system}.default
];
```

### Fedora and Derivatives

Install the [Terra Repository](https://terra.fyralabs.com/), then install ScopeBuddy:

```bash
dnf install ScopeBuddy
```

### Arch Linux

ScopeBuddy is available in the Arch User Repository (AUR) via the [scopebuddy-git](https://aur.archlinux.org/packages/scopebuddy-git)
package. Using an AUR helper such as [yay](https://github.com/Jguer/yay):

```bash
yay -S scopebuddy-git
```

Or, manually:

```bash
git clone https://aur.archlinux.org/scopebuddy-git.git
cd scopebuddy-git
makepkg -si
```

## GUI Configuration

TealMango in the Bazzite community has made a GUI tool to configure scopebuddy.
Well worth to check it out here: [ScopeBuddy-GUI](https://github.com/rfrench3/scopebuddy-gui)
