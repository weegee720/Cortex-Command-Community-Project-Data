function Create(self)

	self.delayTimer = Timer();
	self.overallTimer = Timer();
	self.actionPhase = 0;
	self.fireOn = false;
	self.alliedTeam = -1;

end

function Update(self)

	if self.ID ~= self.RootID then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if MovableMan:IsActor(actor) then
			self.alliedTeam = ToActor(actor).Team;
		end
	end
	if self.Magazine then
		if self:IsActivated() then
			if self.fireOn == false then
				self.Magazine.RoundCount = 500 - self.overallTimer.ElapsedSimTimeMS;
				if self.delayTimer:IsPastSimMS(500) then
					self.delayTimer:Reset();
					self.actionPhase = self.actionPhase + 1;
					self.blink = false;
				end
				if self.actionPhase >= 1 then

					if RemoteExplosiveTableA and RemoteExplosiveTableB then
						for i = 1, #RemoteExplosiveTableA do
							if MovableMan:IsParticle(RemoteExplosiveTableA[i]) and RemoteExplosiveTableB[i] == self.alliedTeam then
								RemoteExplosiveTableA[i].Sharpness = 2;
							end
						end
					end
					AudioMan:PlaySound("Base.rte/Devices/Explosives/AntiPersonnelMine/Sounds/MineDetonate.wav", self.Pos);
					self.fireOn = true;
					self:Reload();
				end
			end
		else
			self.delayTimer:Reset();
			self.overallTimer:Reset();
			self.Magazine.RoundCount = 500;
			self.fireOn = false;
			self.actionPhase = 0;
		end
	end
end