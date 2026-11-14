# Worldbuilt: Modulus

An unofficial mod loader for **Worldbuilt**.

Worldbuilt: Modulus adds an in-game mod menu and supports ZIP entrypoint mods and PCK patch mods without distributing a modified copy of the game.

This is a fork of Worldbuilt: Unbound... and I can't lie these md files are probably partially written by AI, BUT for your information I did not make this md it comes from the original Unbound project.

## Current Version

**0.2.0 MVP**

## Features

- In-game Mods menu
- Enable and disable installed mods
- Persistent enabled states
- ZIP entrypoint mods
- PCK patch mods
- Multiple mods loaded together
- Sidecar manifests for PCK mods
- Manifest-defined input actions
- Duplicate mod ID protection
- Manifest and entrypoint validation
- PowerShell installer and uninstaller
- Existing mods are preserved during uninstall
- A cool subtitle that says Modulus under Worldbuilt! Plus the creator of Worldbuilt made the art for it!!! *Cause I'm buns at art*
- The buttons hover like the Worlbuilt buttons

## Requirements

- Windows
- Worldbuilt Alpha 0.2.3 (Available on Itch.io)
- Mods built for a compatible Godot version

## Installation

Open the Install_Modulus.bat file provided in the zip, and in the terminal paste the path/to/your/executable in the line where it asks for it.

The selected folder must contain the Worldbuilt executable!

## Installing Mods

Place compatible mods inside:

```text
Worldbuilt\mods
```

Launch Worldbuilt and open the `MODS` menu.

```text
[X] Enabled
[ ] Disabled
```

Restart the game after changing a mod's enabled state.

## Supported Formats

### ZIP Entrypoint Mods

```text
ExampleMod.zip
├── manifest.json
└── mods/
    └── author.example_mod/
        └── mod_main.gd
```

### PCK Patch Mods

**Careful using this type of mod for it is not being actively supported... Basically I'm a little lazy and Entrypoint mods are way better.**

```text
ExamplePatch.pck
ExamplePatch.json
```

PCK patch mods can replace existing game resources and may conflict with other patch mods.

See [`docs/MODDING.md`](docs/MODDING.md) for the full format.

Note to self: I should edit the MODDING.md file eventually, but for now it represents how modding works fine.

## Uninstallation

```powershell
powershell -ExecutionPolicy Bypass `
  -File .\installer\uninstall.ps1 `
  -GameDirectory "C:\Path\To\Worldbuilt"
```

The loader is removed, but the `mods` folder is preserved.

## Current Limitations

- Mods require a restart to enable or disable.
- Mods cannot be unloaded while the game is running.
- Patch mods may conflict when replacing the same resource.
- There is no dependency resolver yet.
- There is no graphical installer yet. But there's a installer file now!

## Disclaimer

Worldbuilt: Modulus is an unofficial community project and is definitely affiliated with the developers of Worldbuilt, He's my friend after all :p

Back up save files before testing unfinished mods. If you even know where the save files are haha.
