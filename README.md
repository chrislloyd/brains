# BRAINS

By _Team Mütli_

While we are holed away at Railscamp, a killer infestation of Zombies has broken out in Melbourne. To save the world and to get back to ADSL, we do the only thing we know how: _write Rails apps!_ Write a Rails (or Sinatra or Rack) application which controls a robot facing an impending horde of zombies. Our ability to surf YouTube depends on it.

This is a pre-release of Brains to start you thinking about writing your own Robots.

_Special thanks goes to Daniel Bogan for the amazing sprites! Also, thank you to all the people who helped at various points (Myles, Jeremy, Josh etc)._

## Install

 1. Clone repo: `git clone git://github.com/chrislloyd/brains.git`
 2. Install [Redis](http://code.google.com/p/redis/): `brew install redis`
 3. Install gems: `gem install redis unicorn sinatra json uuid rest-client gosu`
 4. Start Redis: `redis-server /etc/redis.conf`
 5. Start the example robot: `cd client ; unicorn -p 4567`
 6. Start the UI: `cd ui ; ui.rb`
 7. Start the server: `cd server ; ruby server.rb`

## Writing your own Robot

**Note: This API isn't totally tied down. There will definitely be further changes at Railscamp, though it's good enough to start developing against now.**

_The best way to get an understanding of how to write your own bot is to have a look at `client/dummy.rb` which is a very simple robot._

All we require to power a robot is a webserver. For the moment, it must run on [localhost:4567](http://localhost:4567). The game will POST a JSON string to '/' with your robot's _current environment_. This is a hash which looks like this:

    {
      "x": 265.0,
      "y": 200.0,
      "dir": 180,
      "health": 100,
      "energy": 100
      "visible": [
        {"x": 220, "dir": 160, "y": 450, "decay": 0, "type": "zombie", "health": 100, "state": "idle"}
      ]
    }

The `x` and `y` are your position on the board and `dir` is the direction where you are looking. Your health is always out of 100. Energy is also out of 100.

Your health goes down when you are attacked by a Zombie. They do 2 damage with each attack. I'll explain energy later.

The `visible` array shows you all the things which are visible to your player. You get a 60 degree cone of sight and can see 200 pixels into the distance. In the previous example the player can see an `idle` `zombie` at (200,450).

So we POST a JSON string of this data to '/' and then you return a JSON string with what you want your Robot to do. It should look like this:

    {
      "action": "move",
      "x": 1
      "y": -1
    }

Valid actions are `idle`, `move`, `turn` and `attack`. When you turn you also have to specify a `dir` (direction) which is in degrees between 0 and 360.

Each action you make takes energy. At the moment the current energy penalties are:

    idle: 20
    move: -20
    turn: -30
    attack: -100

These, however are likely to change and you should check `server/lib/robot.rb`.

## License

Copyright (c) 2009 Chris Lloyd, Dave Newman, Carl Woodward & Daniel Bogan.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
