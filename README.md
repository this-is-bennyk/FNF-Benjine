<p align="center">
 <img src="https://img.itch.zone/aW1nLzg4NDIyMDcucG5n/original/d3sEO0.png">
</p>

## A Friday Night Funkin' fangame engine made with Godot!

[Click here](#start) to jump straight into getting started with developing on the Benjine.
**Don't always rely on the main branch for looking at Benjine code.** The main branch may have changes farther ahead then the current version of the Benjine you're using. Always be sure use the official releases for stable versions of the Benjine.

The engine actively in development for [FNFVR](https://thisisbennyk.itch.io/funkin-vr) and the second version of [the Bogus mod](https://gamebanana.com/mods/317381). Meant to closely replicate the original feel of FNF, with a flexible backend in mind.  
**All Benjine mods MUST be open source, just like with the original FNF. It also helps avoid folder name clashes for mods.**

Play or get the Benjine on [itch.io](https://thisisbennyk.itch.io/friday-night-funkin-benjine) or [GameJolt](https://gamejolt.com/games/fnf-benjine/722531)!

## Credits / Attributions
**ThisIsBennyK** - Lead developer, programmer, graphic designer, UI designer ([YT](https://www.youtube.com/channel/UCu7zwXQxp4rHmGhW9Dmulkg) / [Twitter](https://twitter.com/thisisbennyk) / [Other Games](https://thisisbennyk.itch.io))  
**DodZonedOut** - Options music (it's called "Grease Monkey" and it slaps) ([YT](https://www.youtube.com/channel/UCWAWJ_hikRCypGpcIY8KZIw) / [Twitter](https://twitter.com/DodZonedOut) / [SoundCloud](https://soundcloud.com/dodzonedout))  
**Sayge3D** - 3D note model ([Carrd](https://sayge3d.carrd.co/))  
**Palladium346** - Extended icons, Funkin' Team icons  

**The Funkin' Crew Inc.** - Art, music, sounds, etc. of the original game ([Newgrounds](https://www.newgrounds.com/portal/view/770371) / [itch.io](https://ninja-muffin24.itch.io/funkin))  
**Godot Engine** - The game engine this game was made in! ([Website](https://godotengine.org) / [License](https://godotengine.org/license))  
**Emilio Coppola** - Creator of Dialogic, the textbox system this game uses. (Dialogic is under copyright (c) 2020 Emilio Coppola.) ([Website](https://dialogic.coppolaemilio.com) / [License](https://github.com/coppolaemilio/dialogic/blob/main/LICENSE))

## Features
### Use Godot as the visual editor for your projects!
- Lay out stages and characters easily in the scene editor
![What Week 1 looks like behind the scenes](https://cdn.discordapp.com/attachments/982020014284607518/982020031749693440/unknown.png "What Week 1 looks like behind the scenes")

- Use practically any feature of Godot to your advantage
![An example of viewports and shaders used to mesh Week 1 and 6 into one level](https://cdn.discordapp.com/attachments/982020014284607518/982022653462315108/unknown.png "An example of viewports and shaders used to mesh Week 1 and 6 into one level")

### Some nice quality-of-life changes
- A slightly redesigned Story Mode menu

![No more strangely disproportionate characters that are out of sync with the beat lol](https://cdn.discordapp.com/attachments/982020014284607518/982026431309697044/unknown.png "No more strangely disproportionate characters that are out of sync with the beat lol")
- All sorts of scroll types

![Downscroll](https://cdn.discordapp.com/attachments/982020014284607518/982027542041100329/unknown.png "Downscroll")
![Middlescroll](https://cdn.discordapp.com/attachments/982020014284607518/982027791107235950/unknown.png "Middlescroll")
![Down-the-middle-scroll (for the osu! and Quaver fans)](https://cdn.discordapp.com/attachments/982020014284607518/982028000717570108/unknown.png "Down-the-middle-scroll (for the osu! and Quaver fans)")
- A bunch of options! (Coming soon: and mods can add their own!)

![Gameplay options](https://cdn.discordapp.com/attachments/982020014284607518/982029464668106812/unknown.png "Gameplay options")
![Sound options (more than just the master volume)](https://cdn.discordapp.com/attachments/982020014284607518/982029515373019137/unknown.png "Sound options (more than just the master volume)")
![Way more control over the controls](https://cdn.discordapp.com/attachments/982020014284607518/982029579222929448/unknown.png "WWay more control over the controls")

### Mods are supported and easy to install!
- Create basic mods that are automatically meshed into the base Benjine...

<p align="center">
 <img src="https://cdn.discordapp.com/attachments/982020014284607518/982021358856859759/unknown.png">
 <img src="https://cdn.discordapp.com/attachments/982020014284607518/982021391706652752/unknown.png">
 <img src="https://cdn.discordapp.com/attachments/982020014284607518/982021451458695168/unknown.png">
 <img src="https://cdn.discordapp.com/attachments/982020014284607518/982021523495866428/unknown.png">
 <img src="https://cdn.discordapp.com/attachments/982020014284607518/982025683784065034/unknown.png">
</p>

- ...or advanced mods that let you create whatever you want!
![For example... FNFVR!](https://cdn.discordapp.com/attachments/982020014284607518/987487770798882846/unknown.png)

<h2 id="start">Getting Started</h2>

- Download the latest version of [Godot](https://godotengine.org) BELOW 4.0 (if you're from the future and Godot 4 finally has a stable release).
- Clone this repo / download this source and extract it into an empty folder.
- Open Godot and press "Import."
- Navigate to the project folder and open the "project.godot" file.
- Click "Import & Edit."
- Now you're ready to mod!

## How to mod using the Benjine
Check the [wiki](https://github.com/this-is-bennyk/FNF-Benjine/wiki) for the latest info on how to mod the Benjine.  
The Benjine assumes you have some sort of experience working with the Godot game engine. Please do not ask me how to use Godot.

## Exporting your mod
In order to be a valid Benjine mod, your mod MUST have:
- A folder with a unique name (ex. whitty, bogus, sonic_exe, etc.)
- A **ModDescription** resource called **mod_desc.tres** in (your mod name)/desc
    - Your mod description and any resources it uses MUST be contained in (your mod name)/desc
    - Make sure to add the package name
- A **ModCredits** resource called **credits.tres**
- A **SongList** resource called **song_list.tres** in (your mod name)/songs

![Here's what that all looks like](https://cdn.discordapp.com/attachments/982020014284607518/984914937862307900/unknown.png "Here's what that all looks like")

To export your mod:
- Open the PCK Packer scene

![Where to find the PCK Packer](https://cdn.discordapp.com/attachments/982020014284607518/982033443753955375/unknown.png "Where to find the PCK Packer")

- Click on the PCK Packer node and fill out the package name and its filename (don't worry about the other options unless you have a specific reason to use them)

![The options for your PCK](https://cdn.discordapp.com/attachments/982020014284607518/982033523131162644/unknown.png "The options for your PCK")

- Run this specific scene by pressing the clapboard with the play arrow, or press F6. You should see a black screen. Once it's done, assuming the packing goes well, you should see something like the example console output. (You may get some warnings about output overflow, but they shouldn't matter if the pack is done correctly.)

![Run the scene](https://cdn.discordapp.com/attachments/982020014284607518/982034345936175214/unknown.png "Run the scene")
![What the output should look like](https://cdn.discordapp.com/attachments/982020014284607518/982034417428099072/unknown.png "What the output should look like")

- Open your project folder (which can be done as shown below).

![Right-click res:// and open it in the file manager](https://cdn.discordapp.com/attachments/982020014284607518/982034584051015680/unknown.png "Right-click res:// and open it in the file manager")

- Your completed PCKs will be in here!

![A completed mod!](https://cdn.discordapp.com/attachments/982020014284607518/984915909523173426/unknown.png "A completed mod!")
