### TF2 Bot Replay

Project that allows to record the inputs of players or bots on a server and play them back using bots.

This **was** a project to potentially replay demos on tf2 servers but has been scrapped due to the fact that STVs don't contain the information needed to create a Player command.

This could work for POV demos or if the server were to run this plugin alongside.

Use the "pup_record", pup_stop" and "pup_load", "pup_playback" commands to record/stop and play back a recording.

`FileHandler.sp` and `GameHandler.sp` contain most of the logic to save/interact with recordings.

`Playback.sp` and `Recording.sp` handle the playing and recording of the current actions.

See the `Tf2BotPuppeteer.sp` file for the main functions

## Dependencies

**This plugin requires the BotPuppeteer extension** which can be found in the release or the seperate repo.

Besides that Dhooks is required as well.

## Status

I don't expect any further work to be done on this, but it might kickstart someones endeavour so I thought I'd publish it.

Enjoy!