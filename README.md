freeaeskype
===========

A free implimintation of a peer to peer secure video tool.

This is the alpha release. Please be patient, ffmpeg has a sync problem.
If the video freezes you can stick with audio only or you can restart the connection.
Please also note that I've not tested it in the wild. It is certainly secure,
at lest as secure as you can get (there is a chance that an attacker could learn your
pass words if the attacker gets access to your account, but there's nothing that I or
anybody else could do about that and it is a security vulnerability of every other
program on the planet, at least as far as I know.)

As I said I've not fully tested it and so you might consider playing with the
audio and or video codecs and bit rates.

You should create a secret gpg key. Then you should create a file encrypted to yourself
that has 65 20+ character long strings in it.

Remember, the volume is raised on the sending side. So if your partner is sending
to low a level for your liking your partner will have to raise it herself.
