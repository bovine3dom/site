---
title: "Remotely Working"
date: 2018-09-11T11:22:30+01:00
---

I really love the freedom that remote working gives me. I can work whenever and wherever the feeling takes me.

However, I often need to run complex simulations that take a lot of grunt. I don't want to lug a heavy laptop around with me all day, so my desk at work is usefully employed to provide a desktop computer.
<!--more-->
Then, my workflow is thus:

- SSH into work machine / MOSH if I'm on a train
- Use tmux in work machine to handle long-running code & deal with patchy WiFi
- Jupyter for bulk of visualisation / coding

I'll go into the vagaries of each in detail; I'll probably update this post often as I think of new things to add.

# SSH

`SSH` is a fantastic multi-tool for remote working. Almost anything you can do at the remote machine you can do over SSH in a much more programmable and, honestly, sane fashion than you may have experienced with Windows Remote Desktop. `mosh` is very similar to SSH but works better on patchier connections. Unfortunately, by its nature, `mosh` can't support the port forwards that I go on to detail in this section, so I generally use `ssh`.

## SOCKS proxy (VPN alternative)

Some universities and employers require you to be on their network to access certain web pages (in my case, journals).

They usually suggest you do this by connecting to their own proprietary VPN which routes all of your traffic through their servers. This is a nightmare for privacy, but, more importantly, for performance---browsing the web feels like treacle.

The trick is to only use your benefactor's network for the pages where you really need it. This is most easily done with a SOCKS proxy and an extension for your browser. I use [FoxyProxy](https://addons.mozilla.org/en-GB/firefox/addon/foxyproxy-standard/).

```
ssh -D8080 your.pc.com

# Or, in ~/.ssh/config

Host your_alias
    HostName        your.pc.com
    DynamicForward  8080 
```

## Port forwarding for Jupyter

Using port forwarding lets you easily use Jupyter on your remote machine from your local device. Simply connect to your machine using the invocation below, start Jupyter on the remote machine (under tmux, for example) if it isn't already running, and then navigate to https://localhost:8888 on your local machine.

```
ssh -L8888:localhost:8888 your.pc.com

# Or, in ~/.ssh/config

Host your_alias
    HostName        your.pc.com
    LocalForward    8888 localhost:8888
```

# tmux

`tmux` is a multi-window terminal multiplexer (i.e. it lets you run multiple processes in a single terminal).

I particularly love it for:

- [vi bindings](https://github.com/bovine3dom/dotfiles/blob/198175dbd49c9f432522cf3223052a6738dc1527/.tmux.conf#L27)
- multi-window (tiling window manager) within the remote machine without X forwarding - uses very little data.
- long lived sessions: wifi disconnect doesn't mean losing your work

With Julia's long start-up and compile times, a long-lived session is a must. I typically run Jupyter for hundreds of days at a time.

# Jupyter

When I migrated from MATLAB to Python, I really missed the way the MATLAB environment encourages experimentation. For me, Jupyter does all of that and more; I find it much easier to reproduce results with Jupyter as the code I've run is saved for posterity unless I go out of my way to delete it. One does have to exercise some self-discipline when re-running cells or running them in a strange order. In practice, I find it works fine, although I know many people are concerned about how careless use of cells can hurt reproducibility.

# "Thin" client

I use an old Thinkpad X220. It has a pretty low resolution display, so I use a bitmap font, the excellent [Dina], for sharpness[^HiDPI-bitmaps]. If anybody knows of a laptop that has a high resolution display, a pointing stick, and a scissor-switch keyboard, please let me know. My current long-term plan for when the X220 dies (and purchasing more on eBay becomes impractical) is to use a [TeX Yoda] or old IBM server keyboard with a high-res tablet---but I'm concerned that it wouldn't be very lap friendly.

[Dina]: https://www.donationcoder.com/Software/Jibz/Dina/
[TeX Yoda]: linkme
[^HiDPI-bitmaps]: If anyone has any recommendations for bitmap fonts to use on HiDPI displays, I'm all ears. I've heard good things about [x3270] but haven't got around to trying it yet. I'm currently trying out [Iosevka], in the hope that I can get the ligatures to work; Fira Code has nicer ligatures but I can't get along with the rest of it. I'm not yet convinced about the density of Iosevka. <!-- Todo: try out Iosevka in mlterm... hyper.js? eugh; consider going back to consolas?--> I might try peep out. Iosevka: need to use "default" character variants; the consolas style one has a funny @ sign.

[x3270]: https://github.com/rbanffy/3270font
<!-- NB: not actually this one-->
[Iosevka]: https://github.com/be5invis/Iosevka/releases
[Peep]: http://zevv.nl/play/code/zevv-peep/

