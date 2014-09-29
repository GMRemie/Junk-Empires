//taken from my Berserker Pack, which was taken from GMDM

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/

	
function EFFECT:Init(data)

	self.Entity:SetModel( "models/gibs/HGIBS.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMaterial( "models/flesh" )
	
	// Only collide with world/static
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )
	
	local phys = self.Entity:GetPhysicsObject()
	if ( phys && phys:IsValid() ) then
	
		phys:Wake()
		phys:SetAngle( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
		phys:SetVelocity( data:GetNormal() * math.Rand( 200, 400 ) + VectorRand() * math.Rand( 10, 100 ) )
	
	end
	
	self.LifeTime = 20
	
	
	local emitter = ParticleEmitter( data:GetOrigin() )
	
		local particle = emitter:Add( "effects/blood_core", data:GetOrigin() )
			particle:SetVelocity( data:GetNormal() * math.Rand( 5, 20 ) )
			particle:SetDieTime( math.Rand( 1.0, 2.0 ) )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand( 128, 256 ) )
			particle:SetEndSize( math.Rand( 48, 64 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetColor( 40, 0, 0 )
				
	emitter:Finish()
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	
	self.LifeTime = self.LifeTime - .01
	return (self.LifeTime > 0)
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	self.Entity:DrawModel()

end



