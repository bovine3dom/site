---
title: "Remote Working"
date: 2017-07-11T11:22:30+01:00
draft: true
---

I really love the freedom that remote working gives me. I can work whenever and wherever the feeling takes me.

However, I often need to run complex simulations that take a lot of grunt. I don't want to lug a heavy laptop around with me all day, so my desk at work is usefully employed to provide a desktop computer.
<!--more-->
Then, my workflow is thus:

- SSH into work machine / MOSH if I'm on a train
- Use tmux in work machine to handle long-running code & deal with patchy WiFi
- Jupyter for bulk of visualisation / coding

I'll go into the vagaries of each in detail.

# SSH

## Keys / password authentication (no)

## Port knocking

## SOCKS proxy

## Port forwarding for Jupyter

## Trusted X Forwarding for clipboard support + little X programmes

# tmux

- turn mouse off
- vi bindings
- multi-window (tiling window manager)
- long lived sessions: wifi disconnect doesn't mean losing your work


## Clipboard management

`xpra` allows you to detach + reattach X sessions. I use it so that I can detach from tmux and then reattach to it at a later date.

Magic script: tmux-x-attach

# "Thin" client

I use an old Thinkpad X220. It has a pretty low resolution display, so I use a bitmap font, the excellent [Dina], for sharpness[^HiDPI-bitmaps]. If anybody knows of a laptop that has a high resolution display, a pointing stick, and a scissor-switch keyboard, please let me know. My current long-term plan for when the X220 dies is to use a [TeX Yoda] with a high-res tablet---but I'm concerned that it wouldn't be very lap friendly.

[Dina]: https://www.donationcoder.com/Software/Jibz/Dina/
[TeX Yoda]: linkme
[^HiDPI-bitmaps]: If anyone has any recommendations for bitmap fonts to use on HiDPI displays, I'm all ears. I've heard good things about [x3270] but haven't got around to trying it yet. I'm currently trying out [Iosevka], in the hope that I can get the ligatures to work; Fira Code has nicer ligatures but I can't get along with the rest of it. I'm not yet convinced about the density of Iosevka. <!-- Todo: try out Iosevka in mlterm... hyper.js? eugh; consider going back to consolas?--> I might try peep out. Iosevka: need to use "default" character variants; the consolas style one has a funny @ sign.

[x3270]: https://github.com/rbanffy/3270font
<!-- NB: not actually this one-->
[Iosevka]: https://github.com/be5invis/Iosevka/releases
[Peep]: http://zevv.nl/play/code/zevv-peep/

