--[[
    Copyright 2018 Lex Robinson

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--]]

-- Modified by Trench, Found here: https://github.com/Lexicality/stencil-tutorial

local matEnemy = Material("ruin/misc/threat_highlighting")
local matFriendly = Material("ruin/misc/threat_highlighting_friendly")
local ply = LocalPlayer()

hook.Add( "PostDrawTranslucentRenderables", "RUIN Threat Highlighting", function()
	if !LocalPlayer():Alive() then return end
	if LocalPlayer().escMenuOpen then return end
	if ply.inMainMenu then return end
	if ply.options.enableThreatHighlighter == false then return end
	
	--RESET THE BUFFER-------
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
	-------------------------
	
	render.SetStencilEnable( true )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 0x1C )
	render.SetStencilWriteMask( 0x55 )

	for _, ent in ipairs( ents.FindByClass( "npc_*" ) ) do
		if ent:Health() <= 0 or ent:GetNoDraw() or !ent:isVisibleToPlayer() or ent:isInjected() then continue end
		ent:DrawModel()
		if IsValid(ent.weaponSkin) then
			ent.weaponSkin:DrawModel()
		end
	end

	render.SetStencilTestMask( 0xF3 )
	render.SetStencilReferenceValue( 0x10 )
	render.SetStencilCompareFunction( STENCIL_EQUAL )
		
	render.SetMaterial(matEnemy)
	render.DrawScreenQuad( )
	render.SetStencilEnable( false )
end ) 

hook.Add( "PostDrawTranslucentRenderables", "RUIN Friendly Highlighting", function()
	if !LocalPlayer():Alive() then return end
	if LocalPlayer().escMenuOpen then return end
	if ply.inMainMenu then return end
	
	-- Reset The Stencil --------------
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
	----------------------------------
	render.SetStencilEnable( true )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 0x1C )
	render.SetStencilWriteMask( 0x55 )

	for _, ent in ipairs( ents.FindByClass( "npc_*" ) ) do
		if ent:Health() <= 0 or ent:GetNoDraw() or !ent:isVisibleToPlayer() or !ent:isInjected() then continue end
		ent:DrawModel()
		if IsValid(ent.weaponSkin) then
			ent.weaponSkin:DrawModel()
		end
	end

	render.SetStencilTestMask( 0xF3 )
	render.SetStencilReferenceValue( 0x10 )
	render.SetStencilCompareFunction( STENCIL_EQUAL )
		
	render.SetMaterial(matFriendly)
	render.DrawScreenQuad( )
	render.SetStencilEnable( false )
end )

