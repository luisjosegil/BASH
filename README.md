## BASH

To be added to /etc/rc.local
>su ljcd -c '/bin/bash ~/LABO/BASH/reverse_ssh.sh &'

It is an script that checks whether ssh tunnels are stablished.
If that's not the case, it tries to establish them again.

It's necessary to configure keepalive params on SSH config.
Open config file
>vi ~/.ssh/config

Add params:

>Host *
> ServerAliveInterval 300

> ServerAliveCountMax 2

