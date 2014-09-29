include('shared.lua')

textureID = surface.GetTextureID( "circle" )

function ENT:Draw()
	
	self.Entity:DrawModel() 
	
	/*
	cam.Start3D2D( self.Entity:GetPos(), self.Entity:GetAngles(), 1 )

		surface.SetTexture( textureID )
		surface.SetDrawColor (255,0,0,35) 
		surface.DrawTexturedRect( -80, -80, 160, 160 )
		
		
	cam.End3D2D()
	*/

end
