# Godot Streaming Overlays

⚠️ Everything is subject to change as I'm actively working on it! ⚠️

This is a collection of various overlays, made from streaming, with Godot! I'm making them live on [Twitch](https://twitch.tv/mreliptik)

## Projects

### Characters overlay

Similar to [Stream avatars](https://store.steampowered.com/app/665300/Stream_Avatars/) where you have characters on screen, representing your current viewers.

![characters ovleray](medias_examples/characters_overlay.gif)

### Facecam overlay

An overlay made to replace your webcam. You can use different images (mouth open/closed) to change based on the mic input.

![facecam ovleray](medias_examples/facecam_overlay.gif)

### Spectrum analyzer

Using the microphone (or any other audio stream) display a spectrum analyzer (frequency analysis). 

![spectrum analyzer](medias_examples/spectrum_analyzer.gif)

### Ridiculous Coding

Turn the [Ridiculous Coding](https://github.com/jotson/ridiculous_coding) addon into an overlay, using websockets to communicate between the editor and the transparent windows (overlay).

![ridiculous coding](medias_examples/ridiculous_coding.gif)

### Alerts Overlay

A dashboard with button acts as a websocket server. An overlay connects to the server and will receive inputs based on the button pressed, triggering effects. Perfect to trigger alerts or custom events/effects.

![alerts overlay](medias_examples/alerts_overlay.gif)

## HOW TO USE

Each project is using a transparent window, so you can set it to the size you want and capture it with your streaming software. 

- For example with OBS, just setup a "Game Capture" source, and check "Allow Transparency" and voilà!

*TODO: Add specific directions for each projects* 

## HOW TO CONTRIBUTE

If you want to contribute, please open an issue before, or join my [Discord](https://discord.gg/83nFRPTP6t) to discuss it! 

I'm open to PR for fixes or improvements, and even new overlays if you want to!


## LICENSES

This project is distributed under the MIT license, check [LICENSE](LICENSE).

Developed by me MrEliptik!
 
- [Twitter](https://twitter.com/mreliptik)
- [Twitch](https://twitch.tv/mreliptik)
- [YouTube](https://www.youtube.com/c/MrEliptik)
- [Discord](https://discord.gg/83nFRPTP6t)
- [All links](https://bento.me/mreliptik)

### CONTRIBUTORS

<a href="https://github.com/MrEliptik/godot_stream_overlays/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=MrEliptik/godot_stream_overlays" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

### ADDONS

- [GIFT](https://github.com/MennoMax/gift) - Twitch chat API addon
- [Ridiculous Coding](https://github.com/jotson/ridiculous_coding) - Ridiculous addon for Godot Engine that adds screenshake and explosions to your coding experience
