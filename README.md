# Brains

A competitive game framework for robots.

**Please be advised:** We believe in documentation driven development. READMEs and blog posts first. This is a work in progress.

## How it works

Here be some rough psuedo-code

1. A level is loaded and the players are selected.
2. The level starts
3. Each "tick" the players are processed randomly.
4. Processing involves: sending the current environment to the process and recieving an action back.
4. Points are scored by completing actions.
5. The game ends when somebody scores X points, or Y ticks have elapsed.
6. The game is then ready for playback.

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
