return [==[

--- V1.16.1 - 01/30/2022 ---

- Fixed broken API dependency preventing the game menu from working.

--- V1.16 - 12/17/2020 ---

- In the lobby doors, replaced ClickDetectors with ProximityPrompts. (Should help mobile noobs.)
- The lift is remodeled somewhat.
- The lift now smoothly goes back up instead of teleporting.
- Changed Lighting.Technology to ShadowMap.
- Simplified some APIs.
- The vote prompt now shows up anytime a player hasn't voted and starts waiting for the next map.
- The anticheat's accuracy is vastly improved.
- MapMakingKit is updated.

--- V1.15.1 - 05/31/2020 ---

- The flat meshes attached to water bodies now automatically scale with their Sizes.
- Lossened up the anticheat a bit.
- The server log now censors logs containing the phrase 'Error filtering message'.
- Changed the lighting to more closely reflect the updated FE2 Map Test.
- Some random bug fixes.

--- V1.15 - 05/20/2020 ---

- More secret stuff.
- Added a couple of anti-exploit scripts.
- Made the WaterLib functions output more helpful error messages.
- The giant screen is resurrected! Albeit for a different purpose.
- Localized some variables in the water FX scripts to improve performance.
- Enabled the anticheat again. Hopefully it doesn't create a bad experience.
- Fixed the map voting prompt behavior (hopefully).
- Added a subtle lift camera animation.
- Added a keybind for the game menu.
- Added some controller support.
- Fixed a glitch where the game menu was forced to show nothing by rapidly switching between two panels.
- Redesigned the HUD.
- Made the ExitRegion behavior almost entirely server-side, further reducing potential exploits.

--- V1.14 - 03/16/2020 ---

- Game now preloads background music.
- Added a blackout effect.
- Gave EventString errors a label.
- Game should now pass player objects to EventScript button handlers. (Unless multiple players touched.)
- Disabled the anticheat for now. (Way too many false-positives!)
- Reduced the part count of the lobby's pipes.
- Made Roblox's topbar less intrusive.
- Made animations easier to copy.

--- V1.13.2 - 01/01/2020 ---

- Added a movement anticheat.
- Added a distance check to buttons.
- Added compatibility for disabled map voting.

--- V1.13.1 - 12/24/2019 ---

- Replaced the lobby music.
- Minor lobby changes.
- Added another room.
- The game no longer opens the map screen when you are not in the lift.

--- V1.13 - 12/23/2019 ---

- Combined all windows into a single full-screen GUI with tabs.
- Fixed map list scaling issues.
- Attempted to replicate lighting effects from FE2 Map Test.
- Added capabilities for loading or unloading maps.
- Changed the way map output is given.
- Got rid of the "IsBreathEnabled" error.
- Added a click sound to the GUI.
- Added a list of third-party assets (not including maps) to the about screen.
- A lot of little adjustments.

--- V1.12 - 08/29/2019 ---

- The game now requires every button to be pressed to escape.
- Pressing the last button while in the ExitRegion now automatically registers an escape attempt.
- EventString no longer stops when a round ends. Only when a new map needs its EventString run.
- Accidentally made the game script huge during dependency cleanup.
- The GUI auto-hides for PC players.

--- V1.11 - 08/25/2019 ---

- Gave characters a deadly seat allergy.
- Added a wall-jump animation.
- Added swimming animations.
- Added swimming support for game controllers.
- Made the music volume match that of FE2 Map Test.
- Updated warning text.
- Adjusted some things a bit more.

--- V1.10 - 08/21/2019 ---

- Changed how the swim script detects water.
	Now there's no chance of falling when swimming through two overlapping water bodies.
	Also, this slightly changed how far down characters can go before they're considered inside water.
- Spectate now resets when the player joins a round.
- Game displays a notification when player attempts to press an inactive button.
- The camera faces forward when the player joins a round.
- All players' votes are given an equal chance at being selected, rather than a majority vote.
- Game will no longer do the voting phase if only one map is installed.
- Adjusted the camera field-of-view to closer match that of FE2.
- Added the option to turn music off.
- Attempted to reposition the dive button. (Not guaranteed to work.)
- Made wall jumps use a BallSocketConstraint.
- Added support for swimming with gamepads.
- Other small adjustments.

--- V1.9 - 08/16/2019 ---

- Completely removed Sandbox Mode.
- Made the StatusFrame script more CPU-efficient.
- Made the intermission notification less intrusive.
- Made the windows managed by one script.
- Made the About window's title bar reflect what's in RepliactedStorage -> GameInfo.
- Added support for scripts needing to use "game.Bindables.BtnPress".
- Moved the spawn to face directly towards the lift.
- Added ghosting players.
- Added limited support for LocalEventScript objects in maps.
- Increased the wall-jump detection distance slightly.
- Fixed a bug where the StatusFrameScript would occasionally error on startup.

--- V1.8 - 08/03/2019 ---

- Fixed the bug where players could not spectate while standing on the lift.
- Fixed the sinking-into-the-lift bug.
- Made the lift step-on and step-off transitions less buggy.
- Added support for group buttons.
- Added button locators to the GUI.
- Added another donate button to the About window.

--- V1.7 - 07/27/2019 ---

- Renamed the game from "FJ's Map Player for FE2 Maps" to "Open Flood Test".
- Added a new MapVotingEnabled option that disables map voting when set to false.
- Added a donate button to the about window.
- Players are no longer trapped in the lift after stepping on. They can just walk off.
- Players will be notified of being on the lift and get a cool camera effect.
- Player characters that somehow fall under the lift will be killed and forced to respawn.
- Modified the map intro text to be simpler. New format: <Title> [<Difficulty>] by <Creator>
- Changed the layout of map tiles in map search.
- Made the text on the panel behind the lift a bit smaller.

--- V1.6 - 07/23/2019 ---

- Geometry of unloaded maps no longer replicate to players, reducing join times.
- Mysterious sounds no longer play.
- Maps can now be added while a server is running. Removing maps is unstable though.
	A custom script must be made to use this feature.
- Maps must now be added to game.ServerStorage.Maps to be used in the game.
- Players can no longer drown while waiting for the next round.

--- V1.5 - 07/20/2019 ---

- Phrases are no longer banned from EventStrings.
- EventStrings are no longer required to be present. They will just fail to run if they have errors.
- Added support for EventScript.
- Merged some code back into MapRunner.
- Made the notification text smaller, because even moderately long text doesn't fit on some screens.
- Added a warning message that's displayed in Roblox Studio

--- V1.4 - 07/13/2019 ---

- Added a delay to music playing to line up with the delay of map behavior.
- Once again changed how characters spawn into maps.
- Removed "by" from the creator text in map search.
- Did some preparations for making different map engines.
- Seperated the script that checks maps' integrity.
- Updated the phrase ban system.
- Made the map search slightly easier to visually navigate.

--- V1.3 - 07/11/2019 ---

- Now players can vote for maps with an advanced map search.
	(No more fussing please!)
- Fixed an issue where players are teleported to the same random spot.
- Further tuned the behavior of behavior tags.
- Converted some ModuleScripts into LocalScripts.

--- V1.2 - 04/30/2019 ---

- Rearranged the GUI to accomodate mobile players.
- Added a shading effect.
- Added icons to the buttons previously needing them.
- Hid the output window button to save room in the UI.
- Modified the about window to save room in the UI.
- Added a GameInfo folder to ReplicatedStorage.

--- V1.1 - 04/21/2019 ---

- Fixed spectating players that left.
- Limited camera zoom distance.
- Timer meter appearance improved.

--- V1.0 - 04/17/2019 ---

- Full release

]==]
