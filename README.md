Want to take it to the next level and prevent casting into a reflector (or cancel mid cast if you press the macro again)?
```
/run if(iconFrame:IsShown() ~= nil and string.find(iconTexture:GetTexture(), "Spell_Frost_FrostWard") ~=nil and string.find(nameText:GetText(), UnitName("target")) ~= nil) then SpellStopCasting() else CastSpellByName("Frostbolt") end
```
That's the template macro for your spells, replace the "Spell_Frost_FrostWard" with "Spell_Shadow_AntiShadow" or "Spell_Fire_FireArmor" for shadow/fire. Replace "Frostbolt" with your spell.
if you're mid cast you'll need to press the macro again to cancel cast.
