Want to take it to the next level and prevent casting into a reflector (or cancel mid cast if you press the macro again)?
```
/run ReflectorCast("frost", "Frostbolt")
```
That's the template macro for your spells, replace the "frost" with "shadow" or "fire" for shadow/fire. Replace "Frostbolt" with your spell.
if you're mid cast you'll need to press the macro again to cancel cast. 

```
/run ReflectorCast("frost", "Frostbolt", {castTime=2.5})
```
Replace castTime with your spell's cast time, or leave it empty like in the first example if you don't care about trying to time the spell for the reflector to fall off.
