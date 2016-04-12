About
=====

Simple concept of a now.js application, pretending to finally become a videogame about miners.

Definition
- UT: Unit of time = 1 minute

- 2D Grid seen from a side
- You control a miner and interact with the mine. There are other miners too (you interact with then undirectly)
- Miners have 200 stamina. If they doesnt rest in a proper place before they run out of it, they'll have to be rescued. This will need miner.deep * UT.
- There's a Loft where miners recover their stamina. After 1 UT in this structure, they'll recover 1 stamina.
- Available actions:
  + Move sideways (1).
  + Dig in any direction.
    * Up: Cant fly.
    * Down: Falls.
    * Sides: Move.
    Stamina and time needed depends on the terrain.
    * Soft Earth (4)
    * Earth (9)
    * Hard Earth (16)
    * Metal: Can't be mined 
  + Climb (2)
  + Build a structure
    * Ladder (4)
  + Items
    * Sleeping bag

actions & reactions
array of actions (like express routing)


Dependencies
============

Mine.js depends on [Brunch]( http://http://brunch.io/ ), install it first!

Dev
===

To start simply execute 

<pre>brunch watch --server</pre>
