supermare  vision fnf 
this is the best fucking engine of all time

BY SILATION AND CYKJLUS!

  # How to compile supermario bros Engine

### Quick Note
- Haxe 4.3.6 and Haxelib 4.2.0 or newer is expected
- This engine ENFORCES the use of local libraries with hxpkg/hmm to prevent issues in relation to `hxvlc`
- The expected library versions are listed within the .hxpkg file. 

if compilation errors arise, Ensure your Haxe version is correct and your haxelibs match what is listed in the .hxpkg file

## Download the prerequisites... (skip this if you already have compiled any fnf project, or any flixel project basically lol)

[Haxe](https://haxe.org/download/)

[Git](https://git-scm.com/downloads)

[VS Community Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe)

within the VS Community Installer, download `Desktop development with c++`

### Download the projects required libraries...
***
#### Recommended Method (Slower)
In a cmd within the project directory, in order run...

```sh
haxelib git hxpkg https://github.com/ADA-Funni/hxpkg add-hmm-compatibility
haxelib run hxpkg install
```


#### Advanced Method (Faster)
> [!IMPORTANT]
> This requires [Rust](https://rust-lang.org/tools/install/) to be installed!

In a cmd within the project directory, in order run...

```sh
haxelib git hxpkg https://github.com/ADA-Funni/hxpkg add-hmm-compatibility
haxelib run hxpkg to-hmm

cargo install --git https://github.com/ninjamuffin99/hmm-rs hmm-rs
hmm-rs clean
hmm-rs install

haxelib fixrepo

haxelib install hmm
haxelib remove grig.audio
haxelib run hmm reinstall grig.audio

haxelib fixrepo
```
***

## Setup Lime
After that is complete, run `haxelib run lime rebuild cpp -release`

Then, run `haxelib run lime test windows -release` and you should be compiling

If you get errors related to lime, run [limeFixer](https://github.com/DuskieWhy/NightmareVision/blob/dev/projFiles/limeFixer.bat) and try again
