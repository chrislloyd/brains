# Brains

A competitive game framework for robots.

**Please be advised:** We believe in documentation driven development. READMEs and blog posts first. This is a work in progress.


## How it works

Here be some rough rules:

1. A level is loaded and the players are selected, their order is randomized.
2. The level starts and runs at 60fps.
3. Robots are sent a request (with the Tick & State) and return Actions.
4. The Round ends when the game says it has or 5 minutes (18k Ticks) have elapsed.
5. The Winners (0..n) are recorded.


## Goals

* Easy to play
* Competitive
* Customizable


## Glossary

* **Game**: The layout and rules. Figures out the initial starting positions, layout of the map, and the rules of the interactions.
* **Robot**:  A character controlled by a computer (other than the game).
* **Round**
* **Tick**

## Decisions

### Round
Brains 1 suffered from a few difficulties:

* Playback was slow due to slow clients and network latencies.
* The competitiveness was difficult to gague - there was no "winner"
* Robots that managed to stay alive first had a massive advange over new robots joining in random positions in the map.
* There was potential to cheat by seeing either the screen positions of Zombies or reading from the unsecured Redis database directly (thanks @atnan!).

Brains 2 fixes these problems by running the game in rounds. Rounds have a start and and finish and the results of each tick is kept in a [Write Ahead Log](http://en.wikipedia.org/wiki/Write-ahead_logging). This means both the computation and the rendering of a round are entirely de-coupled. The round could be re-rendered in any sort of way from the log. The potential to cheat is nullified because the only state the system exposes is what's explicitely sent to the robots. It's also more fun because the rounds are shorter and people can "win" a round.

### Making a game is just as fun as making a robot

At Railscamp, we ended up changing the game to balance it. We introduced Tanks and Witches to help combat teams of bots who were owning the map. We adjusted energy costs. This was some of the most fun programming I've done. This should be open to robot, not just the robots that we make.

### There needs to be a fixed set of parameters
Things like actions the robots can take, the world size and sprites should be global. You shouldn't have to learn entirely new semantics for each game a robot plays.

### Communication needs to be baked in
With Brains 1, lots of people ended up writing databases to help their robots communicate. That's fine, but I'd love to make an official channel for that communication so spectators can see it but so robots that don't know each other can work together.


## World

The game board is 640x480. The coordinate system starts at 0, and (0,0) is in the top left.

The list of available sprites is global and set by Brains (though open to additions). The art used for the sprites themselves can be determined by the renderer.


## Replay Data Format

Write ahead log of gameplay state. Each entry has an associated timestamp.

```
START  game_url round_id [{<url> <label>}, ...]
TICK   0
DRAW   sprite_id x y
UPDATE "bot1" {env} ["actions", ...]
...
TICK   1
...
END    [<winner_id>, ...]
```

*Note:* I'm sure this isn't perfect. I'm trying to do my best to emulate the update/draw/flush framebuffer cycle of traditional games. One thing I could consider is adding a z-index to the `DRAW` cmd. That would let games show things like projectiles etc.

If this format is written to the filesystem, please use the the extension `.brainplay`.


## Request Protocol

POST <url> tick=123 state="{}"

*TODO* Think about wether `state` should be a bit more formally defined.


## Action Protocol

```
SAY   msg
UP
DOWN
LEFT
RIGHT
LOOK  x,y
A
B
```

Commands are "\n" separated. Robots can send multiple commands each tick. An example response where the player turns to face an enemy and "shoots":

```
CUR 27,32
A
```

* SAY: Communicate with the game. Like using a headset.
* UP/DOWN/LEFT/RIGHT: Move a bot like a d-pad.
* LOOK: Change orientation or cursor like a mouse or thumbstick
* A/B: Primary and secondary actions.
