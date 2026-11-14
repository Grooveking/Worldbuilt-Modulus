# Worldbuilt: Modulus

An unofficial mod loader for **Worldbuilt**.

Worldbuilt: Modulus adds an in-game mod menu and supports ZIP entrypoint mods and PCK patch mods without distributing a modified copy of the game.

This is a fork of Worldbuilt: Unbound! I haven't gotten to fully rewriting the md files.

## Current Version

**0.2.0 MVP**

## Features

- Compatible with linux and windows
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
- A cool subtitle that says Modulus under Worldbuilt! Plus the creator of Worldbuilt made the art for it!!! *Cause I'm not great at art*
- The buttons hover like the Worlbuilt buttons

## Requirements

- Windows or Linux
- Worldbuilt Alpha ver. 0.2.3 or ver. 0.3.0 (Available on Itch.io)
- Mods built for a compatible Godot version

**Linux Extra Requirements**
- Powershell (pwsh)
- The permission to run shell files

## Windows Installation

Open the Install_Modulus.bat file provided in the zip, and in the terminal paste the path to your executable if it asks

The selected folder must contain the Worldbuilt executable!

## Linux Installation

Open the install.sh file (As a program not as a text file)
Then paste the path to your executable if it asks

Note: If you get warned that Powershell is not installed then get it installed!
See troubleshooting if you still can't get it to install

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

## Uninstallation
**THIS DOES NOT WORK JUST DELETE EVERYTHING EXCEPT THE EXECTUABLE AND THAT WORKS AS UNINSTALLING**

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

## Troubleshooting
If your on windows or linux and cannot get the install_modulus.bat or install.sh files to work you can run the the main install file manually, here's how:

- Go into the installer folder and right click, then open in terminal. (or you can use cd in terminal)
- type ./install.ps1 and if your on windows it should just run, if your on linux make sure you have powershell installed.

### In the case you don't have permissions to run powershell commands
You can just manually drag the files to your worldbuilt install actually!
- Drag the addons folder and the override.cfg file located inside of payload into the folder containing your worldbuilt executable.
- Then create a new folder inside your folder with the executable called "mods". This is the folder where you can place the zip mods (or pck mod).

```text
Folder-with-Executable
├── WorldbuiltAlpha.exe
├── mods/
├── addons/
└── override.cfg
```

## Disclaimer

Worldbuilt: Modulus is an unofficial community project and is not affiliated with the owner of Worldbuilt.

Back up save files before testing unfinished mods. If you even know where the save files are haha.
