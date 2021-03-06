function Create(self)
	self.GibTimer = Timer();
	self.GibTimer:SetSimTimeLimitMS(1000 + self.InventorySize * 100);
	-- Choose a random horizontal direction
	local randomDirection = math.random() > 0.5 and 1 or -1;
	-- Randomize velocities
	self.RotAngle = RangeRand(0, math.pi * 2);
	self.AngularVel = -randomDirection * math.random(1, 10);
	self.Pos = Vector(self.Pos.X - randomDirection * math.random(99), self.Pos.Y);
	-- Try not to fly off the edge in non-wrapping scenes
	if not SceneMan.SceneWrapsX then
		randomDirection = self.Pos.X > (SceneMan.SceneWidth - 99) and -1 or (self.Pos.X < 99 and 1 or randomDirection);
	end
	self.Vel = Vector(randomDirection * math.random(1, 20), 40);
end
function Update(self)
	-- Apply damage to the actors inside based on impulse forces
	if self.TravelImpulse.Magnitude > self.Mass then
		for i = 1, self.InventorySize do
			local actor = self:Inventory();
			if actor and IsActor(actor) and string.find(actor.Material.PresetName, "Flesh") then
				actor = ToActor(actor);
				-- The following method is a slightly revised version of the hardcoded impulse damage system
				local impulse = self.TravelImpulse.Magnitude - actor.ImpulseDamageThreshold;
				local damage = impulse/(actor.GibImpulseLimit * 0.1 + actor.Material.StructuralIntegrity * 10);
				actor.Health = damage > 0 and actor.Health - damage or actor.Health;
				actor.Status = actor.Status < Actor.DYING and Actor.UNSTABLE or actor.Status;
			end
			self:SwapNextInventory(actor, true);
		end
	end
	if self.GibTimer:IsPastSimTimeLimit() then
		self:GibThis();
	elseif (self.Vel.Largest + math.abs(self.AngularVel)) > 5 or self.AIMode == Actor.AIMODE_STAY then
		self.GibTimer:Reset();
	else
		self:OpenHatch();
	end
end
function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end