local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
	local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
	self:SetButtons(newbuttons)
end

hook.Add("SetupMove", "RUIN Disable Jump", function(ply, mvd, cmd)
	if mvd:KeyDown(IN_JUMP) then
		mvd:RemoveKeys(IN_JUMP)
	end
end) 