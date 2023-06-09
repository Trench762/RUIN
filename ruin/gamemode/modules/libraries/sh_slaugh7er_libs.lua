function math.RemapClamped(i,m,M,mm,MM)
    return math.Clamp( math.Remap(i,m,M,mm,MM), mm, MM )
end

if CLIENT then
    // simple 2d stencil
    stencil = stencil or {}

    function stencil.Enable(b)
        render.SetStencilEnable( b!= nil and b or true)
        timer.Create( "stencil.Enable.Disable", 0, 1, stencil.Disable )
    end
    stencil.Start = stencil.Enable
    stencil.Begin = stencil.Enable

    function stencil.Disable()
        render.SetStencilEnable(false)
        stencil.Reset()
        timer.Remove( "stencil.Enable.Disable" )
    end
    stencil.Finish = stencil.Disable
    stencil.End = stencil.Disable

    function stencil.Reset()
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()
    end

    // run before drawing, everything drawn after this is called will be removed from any upcomming draw calls called after 'stencil.Remove()'
    function stencil.Apply() 
        stencil.Enable()
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
    end
    stencil.Set = stencil.Apply

    // run before drawing, everything drawn after this will be spliced into using the stecil provided previously in the 'stencil.Apply()' and removed
    function stencil.Remove()
        stencil.Enable()
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)
    end
    function stencil.Keep()
        stencil.Enable()
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)
    end
    stencil.Preserve = stencil.Keep
    stencil.RemoveInvert = stencil.Keep
    stencil.RemoveInverted = stencil.Keep
    // simple 2d stencil

    -- function draw.Arc( x, y, radius, startAng, endAng, step, color )
    function draw.TexturedArc( x, y, radius, width, minAng, maxAng, resolution, color ) 
        if !radius then error( "attempt to index 'radius' (a nil value) (radius from x, y)" ) end 
        if !width then error( "attempt to index 'width' (a nil value) (width of the arc (can be negitive))" ) end 
        if !minAng then error( "attempt to index 'minAng' (a nil value) (arch start leftmost (think a clock face))" ) end 
        if !maxAng then error( "attempt to index 'maxAng' (a nil value) (arch end rightmost (think a clock face))" ) end 
        local poly, ppoly 
        resolution = math.Clamp( resolution or 0, 3, 256 )
        if width < 0 then 
            poly = {}
            poly[1] = { x = x, y = y }
            for i = minAng-90, maxAng-90, resolution do
                table.insert(poly, {
                    x = x + math.cos(math.rad(i)) * radius,
                    y = y + math.sin(math.rad(i)) * radius,
                })
            end
            ppoly = {}
            ppoly[1] = { x = x, y = y }
            for i = minAng-90, maxAng-90, resolution do
                table.insert(ppoly, {
                    x = x + math.cos(math.rad(i)) * (radius+width),
                    y = y + math.sin(math.rad(i)) * (radius+width),
                })
            end
        else
            ppoly = {}
            ppoly[1] = { x = x, y = y }
            for i = minAng-90, maxAng-90, resolution do
                table.insert(ppoly, {
                    x = x + math.cos(math.rad(i)) * radius,
                    y = y + math.sin(math.rad(i)) * radius,
                })
            end
            poly = {}
            poly[1] = { x = x, y = y }
            for i = minAng-90, maxAng-90, resolution do
                table.insert(poly, {
                    x = x + math.cos(math.rad(i)) * (radius+width),
                    y = y + math.sin(math.rad(i)) * (radius+width),
                })
            end
        end

        surface.SetDrawColor(color or Color(255,255,255))
        stencil.Enable()
        stencil.Apply()
        surface.DrawPoly(ppoly)
        stencil.Remove()
        surface.DrawPoly(poly)
        stencil.Disable()
    end

    function draw.Arc( ... )
        draw.NoTexture()
        draw.TexturedArc( ... )
    end


    local blur = Material( "pp/blurscreen" )
    function draw.BlurPanel( panel, amount, color )
        local x, y = panel:LocalToScreen(0, 0)
        local w, h = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        amount = amount or 4
        for i = 1, 5 do
            blur:SetFloat("$blur", (i / 3) * amount)
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect( x*-1, y*-1, w, h )
        end
        if color then draw.RoundedBox( 0, 0, 0, w, h, color ) end
    end
end
