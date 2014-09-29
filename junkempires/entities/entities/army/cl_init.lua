include('shared.lua')

textureID = surface.GetTextureID( "circle" )

function ENT:Draw()
	
	self.Entity:DrawModel() 
	
	if(self.Entity:GetNWBool("isSelected")) then
		cam.Start3D2D( self.Entity:GetPos() - Vector(0,0,2), self.Entity:GetAngles(), 1 )

		surface.SetTexture( textureID )
		surface.SetDrawColor (255,0,0,255) 
		surface.DrawTexturedRect( -8, -8, 15, 15 )
		
		cam.End3D2D()
	end

end

