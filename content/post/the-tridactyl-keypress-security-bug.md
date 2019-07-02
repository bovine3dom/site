---
title: "The Tridactyl Keypress Security Bug"
date: 2019-06-23T17:15:25+01:00
draft: true
---

What follows is a wordier write-up of our first real brush with (in)security from my personal perspective. If you're purely interested in the mitigations, head to our [GitHub repository](https:///github.com/tridactyl/tridactyl)---or just update Tridactyl to version 1.16.1 or 1.14.13 by going to `about:addons` in Firefox, right-clicking Tridactyl's listing, and clicking "Find Updates". Once it has downloaded (it will look like it's hanging---it isn't), restart Firefox and you're done. At the time of writing, [about 60% of users have a patched version](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/statistics/usage/versions/?last=30). <!-- make this point to the corresponding issue -->

<!--more-->

---

On the morning of Friday, 14th June, 2019, a user came into Tridactyl's [Riot.im](https://riot.im/app/#/room/#tridactyl:matrix.org) chat room and asked:

> can someone ELI5 - what's stopping a webpage from intracting with tridactyl? eg. sending keypress events to the command line

It was quite a reasonable question. For those not in the know, Tridactyl is a Firefox extension which makes it all a little bit more like Vim. Importantly, it allows you to automate many actions---from "open this link in a new tab" and "open the current page in `mpv`" to "shutdown my computer if I visit `emacs.org`---which you wouldn't want any web page you visit to be able to trigger.

glacambre, another Tridactyl developer, quickly responded with the simple design cmcaine came up with in the first days of Tridactyl:

> The webpage can emit keypress events for Tridactyl but the `isTrusted` attribute of said events will be set to false while user-generated events have them set to `true`. That's what Tridactyl uses in order to know what the keypress events it should register.

Publicly, this was the end of the matter---a good question answered authoritatively. It's what we've come to expect from glacambre.

---

Two hours later, glacambre posted a pretty sober message in our private "devs"[^devs] team on GitHub.

> # isTrusted value isn't checked anymore
>
> Tridactyl started checking for the isTrusted attribute of key events in
>
> [48cedc058bb09b2a8ad898d8caa3455adc510b1e](https://github.com/tridactyl/tridactyl/commit/48cedc058bb09b2a8ad898d8caa3455adc510b1e).
>
> [d1e6a8653913a15b132f11c7731ca3a1c1bd41d6](https://github.com/tridactyl/tridactyl/pull/962/commits/d1e6a8653913a15b132f11c7731ca3a1c1bd41d6)
> removed that code but didn't re-add this check anywhere. So we might currently be vulnerable to pages generating events and interacting with the command line (I haven't checked yet).

Yep---the key security property that was protecting Tridactylys[^dem] from nefarious websites _just wasn't there_. I've no idea why glacambre decided to check whether this was in the code. I _knew_ it was there; there's no way I would have bothered to look.

I replied with my characteristic composure:

> F\*\*\* me
>
> Once we get this sorted it would be nice to have an e2e test that checks for this vulnerability.

The bug was introduced in [September 2018](https://github.com/tridactyl/tridactyl/pull/962)---merged by me---and persisted until June 2019. This was, and is, embarrassing. 

Any website could send keypresses to Tridactyl and Tridactyl would merrily run them as if the user had pressed them. This is quite terrifying for users who have our `native messenger` installed which allows you to execute anything you want in your shell; our fear was that, now, any website you visited would have that same pleasure.

# Mitigation

It was very simple to reinstate the checks; cmcaine committed an initial fix at 10AM on the day we found the issue and released 1.16.0 within hours. cmcaine and I manually built and backported the patch to the 1.14.x release by Saturday. We did this pretty much immediately before concerning ourselves with what the impact of the bug might be.

For fear of alerting nefarious individuals, we kept the patch secret until approximately 50% of Tridactyl users had it. We then kept the patch secret for a bit longer because I was in the middle of moving to a new flat and I wanted to be available at the time of disclosure to answer people's questions.

## addons.mozilla.org (AMO)

The AMO makes backporting a much bigger pain than it needs to be. Firstly, its versioning system assumes that `x.x.x < y.y.y.y for all x,y` (which we only found out from trial and error). Secondly, if you are rapidly signing releases---as one probably is if one is backporting to multiple releases at once---the AMO will irreversibly disable any versions which were in its reviewing queue. Finally, the AMO reports the most recently-updated version as the "latest version" on your own page, and the "add to Firefox" button defaults to that, meaning people can install an 'old' version and then as soon as they restart their browser get hit with a scary permission prompt asking for all the new permissions the real latest version requires.

I think the documentation could really benefit from a page that says "you found a security bug: what next?". It really gave us some extra headaches that we could have done without. Backporting is a niche use-case on the AMO, but when it matters, it really matters.

We disabled all affected Tridactyl versions and deleted them from our buildbot.

# Investigation

There's a famous adage in the airline industry that goes something like this:

> I've never seen a plane crash where there was a single root-cause. Usually, 9 or 10 things went wrong and if any one of those things hadn't gone wrong, the plane would have been fine.

For us, a whole host of things actually _went right_, which greatly limited the damage the bug could have done---and perhaps explains why no-one had complained to us about their bank details or SSH keys being stolen.

## What went wrong

- I didn't review a large PR thoroughly enough

- One of our developers missed a comment that said `// Ignore JS-generated events for security reasons.`

- Our `mpv` hint-mode default bind `;v` didn't escape the `href`s it was fed so characters which were not escaped, e.g. `|`, could be used to start new shell commands after mpv exited.

- Our tests didn't (and don't) check that our key security assumptions are valid


## What went right

- the `iframe` our command line lives in contains just a dumb textbox for which Firefox handles the key events---so no website could execute arbitrary ex-commands

- `href`s are percent-encoded which makes it much harder to give arguments to any shell-command.


## Overall impact

- Any website could trigger binds outside of our command line for nuisance attacks - adding bookmarks, closing Firefox, etc.

    - It would be hard for a website to trigger any non-default binds as it would have no way of knowing which those were.

- If the native messenger was installed, shell commands (without any arguments, to the best of our knowledge) could be executed.

    - Very creative attacks piping the output of `mpv` into another command could be possible but would require some amount of thought. We've spent some time trying to craft attacks but haven't managed it yet.

For clarity: if you have the native messenger installed and you are on an unpatched version, it is possible that any website could execute commands in your shell and 


# Prevention

This bug was really embarrassing and potentially quite dangerous, so we'd really like to prevent them from happening again. Our plan is thus:

- Require two people to review any large PRs

- Try to persuade our contributors to submit smaller PRs

- Include automated tests for as many of our key security properties as we can manage

The first point---having more eyes on the code---is something that everyone reading this post could help with. The majority of our pull requests are quite small and could be reviewed in only a few minutes of your time. Just click the "watch" button on the repository and occasionally pop in and send us your thoughts on whatever we're doing. I would encourage anyone horrified by this bug to get involved.

# Disclosure

You're reading it! :)

Please tell your Tridactyl-using friends to update to version 1.16.0+ or 1.14.13+. All other Tridactyl 1.14.x and 1.15.x are affected. Tridactyl 1.13.x and lower are not affected.

# Acknowledgements

- Hat-tip to skeeto on [Reddit](https://www.reddit.com/r/firefox/comments/c1afp3/is_this_a_legitimate_tridactyl_update/) for noticing our slightly dodgy flurry of backports for Firefox ESR. Thanks for sounding the alarm and then keeping the reason for the subterfuge quiet when I sheepishly explained and asked!

- Thanks to The Compiler of Qutebrowser fame for giving us some sound advice on how to disclose the vulnerability when we asked for it.

- I'm very grateful to all of the Tridactyl developers for coming together to work out how serious this bug was and mitigate it.

- Finally, we must thank swalladge for asking the question in the first place!

[^devs]: We have an excellent logo for the developer team which is exclusively visible to them. If this isn't incentive enough to make the 80 or so commits it takes to join the team, I don't know what is.
[^dem]: This is the demonym(?) for people who use Tridactyl, I think. Disclaimer: I only studied Latin at school.
