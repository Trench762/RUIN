hook.Add("EntityEmitSound", "RUIN Weapon System Extened Weapon Use Prevent Ammo Pickup Sound", function(data)
    if data.SoundName == "items/ammo_pickup.wav" then return false end
end)