Sintt = {}
Sintt.CombatUpdate = {}

local defaults = {
    party = false,
    raid = true,
}

local t = CreateFrame('Frame')
t:SetScript('OnEvent', function(self, event, ...)
    Sintt[event](Sintt, ...)
end)

local print = function(msg)
    print(format('|cffFF0000SI|r %s', msg))
end

t:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
function Sintt:COMBAT_LOG_EVENT_UNFILTERED(_, eventType, _, srcGUID, _, _, _, dstName, _, spellId, spellName, _, missType, enemySpell)
    if(srcGUID == UnitGUID('player')) then
        if(eventType == 'SPELL_INTERRUPT') then
            Sintt:Interrupt(_, eventType, _, srcGUID, _, _, _, dstName, _, spellId, spellName, _, missType, enemySpell)
        elseif(eventType == 'SPELL_MISSED') then
            Sintt:Missed(_, eventType, _, srcGUID, _, _, _, dstName, _, spellId, spellName, _, missType, enemySpell)
        end
    end
end

function Sintt:Missed(_, _, _, _, _, _, _, dstName, _, spellId, spellName, _, missType)
    if (spellId == 47528) -- Mind Freeze
    or (spellId == 47476) -- Strangulate
    or (spellId == 80965) -- Skull Bash cat
    or (spellId == 80964) -- Skull bash bear
    or (spellId == 34490) -- Silencing Shot
    or (spellId == 2139) -- Counterspell
    or (spellId == 85285) -- Rebuke
    or (spellId == 15487) -- Silence
    or (spellId == 1766) -- Kick
    or (spellId == 57994) -- Wind Shear
    or (spellId == 19647) -- Spell Lock (maybe?)
    or (spellId == 6552) -- Pummel
    or (spellId == 72) -- Shield Bash
    or (spellId == 78675) -- Solar Beam
    then
        if (missType == "MISS") 
        or (missType == "DEFLECT")
        or (missType == "REFLECT")
        or (missType == "BLOCK")
        or (missType == "EVADE")
        or (missType == "RESIST") -- If dodge/parry then interrupt was late and is registering via client/server lag. Don't bother announcing.
        then
            l2interrupt:doalert(spellName, dstName, "MISS")
        end
    end
end

function Sintt:Interrupt(_, eventType, _, srcGUID, _, _, _, dstName, _, spellId, spellName, _, missType, enemySpell)
    self.abilityduration="0"
    -- 2 Seconds
    if (spellId == 57994) -- Wind Shear
    then
        self.abilityduration="2"
    end
    -- 3 Seconds
    if (spellId == 34490) -- Silencing Shot
    then
        self.abilityduration="3"
    end
    -- 4 Seconds
    if (spellId == 47528) -- Mind Freeze
    or (spellId == 6552) -- Pummel  
    or (spellId == 85285) -- Rebuke
    then
        self.abilityduration="4"
    end
    -- 5 Seconds
    if (spellId == 80965) -- Skull Bash cat
    or (spellId == 93985) -- Skull Bash cat
    or (spellId == 93983) -- Skull Bash cat
    or (spellId == 82365) -- Skull bash bear
    or (spellId == 80964) -- Skull Bash bear
    or (spellId == 1766) -- Kick
    or (spellId == 15487) -- Silence
    or (spellId == 78675) -- Solar Beam
    then
        self.abilityduration="5"
    end
    -- 6 Seconds
    if (spellId == 19647) -- Spell Lock (maybe?)
    or (spellId == 72) -- Shield Bash
    then
        self.abilityduration="6"
    end
    -- 7 Seconds
    if (spellId == 47476) -- Strangulate
    then
        self.abilityduration="7"
    end
    -- 8 Seconds
    if (spellId == 2139) -- Counterspell
    then
        self.abilityduration="8"
    end
    Sintt:doalert(enemySpell, dstName, "COUNTERSPELL")
end

function Sintt:doalert(ability, mob, msgtype)
    if (msgtype == "MISS") then
	    self.warningmessage = string.gsub(string.gsub("Warning! {t} resisted my {a}!", "{t}", mob), "{a}", ability)
    elseif (msgtype == "COUNTERSPELL") then
	    self.warningmessage = string.gsub(string.gsub(string.gsub("Interrupted {s} by {t}  ({d}s)", "{s}", ability), "{t}", mob), "{d}", self.abilityduration)
    end

    SendChatMessage(self.warningmessage, "SAY")
end

