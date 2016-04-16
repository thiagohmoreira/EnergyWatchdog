# Energy Watchdog

This is an [OpenComputers](https://oc.cil.li) / [PHP](https://secure.php.net/)
implementation of a controller for reactor and turbines from
[Big Reactors](http://www.big-reactors.com/) with capacitors from
[EnderIO](http://enderio.com/).

## What it will do?

The main idea is to make an script that will monitor a capacitor bank, a reactor
and some turbines, to be as efficient as possible in terms of fuel consumption,
energy generation and availability.

On top of that, it should communicate over the network with a real server, to
keep records, show some graphs and allow you to check and control your energy
plant even when not logged to the game.

## What it already does?

Only really basic functions are ready at the moment. The most useful one is
reactor_control.lua that will check one capacitor and when it reaches 50%
charge, it will turn on the reactor. Once the capacitor reaches 95%, it will
shut down the reactor. There is no control on reactor configs, no checks at all,
really simple for now.

Also on the PHP side nothing is really functional, there is just a script I used
to test connectivity.

## Installation

TODO
