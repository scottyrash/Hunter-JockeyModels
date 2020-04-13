if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/infected/hunter.mdl"}
ENT.StartHealth = 350
ENT.CanMutate = false
ENT.CollisionBounds = Vector(18,18,70)

ENT.Faction = "FACTION_ZOMBIE"

ENT.MeleeAttackDistance = 40
ENT.MeleeAttackDamageDistance = 60
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 50
ENT.AttackablePropNames = {"prop_physics","func_breakable","prop_physics_multiplayer","func_physbox"}

ENT.BloodEffect = {"blood_impact_red"}

ENT.tbl_Animations = {
        ["Idle"] = {ACT_IDLE},
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["Attack"] = {"cptges_Melee_01","cptges_Melee_02","cptges_Melee_03","cptges_Melee_04"}, 
        ["RangeAttack"] = {ACT_JUMP},
}

ENT.tbl_Sounds = {
	["Alert"] = {
            "cpt_l4d2/hunter/voice/warn/hunter_warn_10.wav",
            "cpt_l4d2/hunter/voice/warn/hunter_warn_14.wav",
            "cpt_l4d2/hunter/voice/warn/hunter_warn_16.wav", 
            "cpt_l4d2/hunter/voice/warn/hunter_warn_17.wav",
            "cpt_l4d2/hunter/voice/warn/hunter_warn_18.wav",
        },
        ["RangeAttack"] = {
            "cpt_l4d2/hunter/voice/attack/hunter_attackmix_01.wav",
            "cpt_l4d2/hunter/voice/attack/hunter_attackmix_02.wav",
            "cpt_l4d2/hunter/voice/attack/hunter_attackmix_03.wav",
            "cpt_l4d2/hunter/voice/attack/shriek_1.wav",
        },
        ["Death"] = {
            "cpt_l4d2/hunter/voice/death/hunter_death_02.wav",
            "cpt_l4d2/hunter/voice/death/hunter_death_04.wav",
            "cpt_l4d2/hunter/voice/death/hunter_death_06.wav",
            "cpt_l4d2/hunter/voice/death/hunter_death_07.wav",
            "cpt_l4d2/hunter/voice/death/hunter_death_08.wav", 
        },
        ["Idle"] = {
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_01.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_04.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_05.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_06.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_07.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_08.wav",
            "cpt_l4d2/hunter/voice/idle/hunter_stalk_09.wav",
            "cpt_l4d2/hunter/voice/alert/hunter_alert_01.wav",  
            "cpt_l4d2/hunter/voice/alert/hunter_alert_02.wav",
            "cpt_l4d2/hunter/voice/alert/hunter_alert_03.wav",
            "cpt_l4d2/hunter/voice/alert/hunter_alert_04.wav", 
            "cpt_l4d2/hunter/voice/alert/hunter_alert_05.wav",
            "bacteria/hunterbacteria.wav",
            "bacteria/hunterbacterias.wav",
        },
        ["Pain"] = {
            "cpt_l4d2/hunter/voice/pain/hunter_pain_05.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_08.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_09.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_12.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_13.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_14.wav",
            "cpt_l4d2/hunter/voice/pain/hunter_pain_15.wav",
        },
        ["Bacteria"] = {
            "bacteria/hunterbacteria.wav",
            "bacteria/hunterbacterias.wav",
        },
        ["FootStep"] = {
            "cpt_l4d2/hunter/foot/hunter_foot_l01.wav",
            "cpt_l4d2/hunter/foot/hunter_foot_l02.wav",
            "cpt_l4d2/hunter/foot/hunter_foot_r01.wav",
            "cpt_l4d2/hunter/foot/hunter_foot_r02.wav", 
        },
        ["Hit"] = {
            "cpt_l4d2/hit/claw_hit_flesh_1.wav",
            "cpt_l4d2/hit/claw_hit_flesh_2.wav",
            "cpt_l4d2/hit/claw_hit_flesh_3.wav",
            "cpt_l4d2/hit/claw_hit_flesh_4.wav",
        },
        ["Killed"] = {
            "cpt_l4d2/survival_medal.wav",
            "cpt_l4d2/survival_playerrec.wav",
            "cpt_l4d2/survival_teamrec.wav", 
        } 
}                 

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE,CAP_MOVE_CLIMB,CAP_MOVE_JUMP}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsAttacking = false 
        self.IsRangeAttacking = false
	self.NextRangeAttackT = 0
	self.NextLeapDamageT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnPossessed(possessor)
	possessor:ChatPrint("Possessor Controls:")
	possessor:ChatPrint("LMB - Melee attack")
	possessor:ChatPrint("Jump - Special attack")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self.IsPossessed then
		self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:GetPos()):Angle().y,0))
	end
        if self.IsRangeAttacking && CurTime() > self.NextLeapDamageT then
		self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		self.NextLeapDamageT = CurTime() +0.2
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	if(event == "mattack") then
		if arg1 == "power" then
                        self:PlaySound("Attack")

			self:DoDamage(self.MeleeAttackDamageDistance *1.5,self.MeleeAttackDamage,self.MeleeAttackType)
		else
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
                end     
		return true
	end
	if(event == "emit") then
		if arg1 == "Idle" then
			self:PlaySound("Idle",105,96,96,true)
		end
                if arg1 == "Alert" then
			self:PlaySound("Alert",105,96,96,true)
		end 
                if arg1 == "Pain" then
			self:PlaySound("Pain",105,96,96,true)
		end
                if arg1 == "Attack" then
			self:PlaySound("Attack",105,96,96,true)
		end 
                if arg1 == "RangeAttack" then
			self:PlaySound("RangeAttack",105,96,96,true)
		end 
                if arg1 == "Death" then
			self:PlaySound("Death",105,96,96,true)
		end 
                if arg1 == "Hit" then
			self:PlaySound("Hit",92,92,102,true)
		end
                if arg1 == "FootStep" then
			self:PlaySound("FootStep",90,90,100,true)
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	self:DoRangeAttack()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
        self:PlayAnimation("Attack")
	self.IsAttacking = true
	self:AttackFinish()
        timer.Simple(0.6,function()
		if self:IsValid() then
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if self:CanPerformProcess() == false then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	if CurTime() > self.NextRangeAttackT then
		self:PlaySound("RangeAttack",75)
		self:PlayAnimation("RangeAttack")
		self.IsRangeAttacking = true
		self:SetGroundEntity(NULL)
		if !self.IsPossessed then
			self:SetLocalVelocity(((self:GetEnemy():GetPos() +self:OBBCenter()) -(self:GetPos() +self:OBBCenter())):GetNormal() *400 +self:GetForward() *700 +self:GetUp() *300 + self:GetRight() *0)
		else
			self:SetLocalVelocity(((self:Possess_AimTarget()) -(self:GetPos() +self:OBBCenter())):GetNormal() *300 +self:GetForward() *700 +self:GetUp() *300 + self:GetRight() *0)
		end
		self:AttackFinish()
		self.NextRangeAttackT = CurTime() +math.Rand(4,6)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmg,dmginfo,hitbox)
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
        self:PlaySound("Death")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end 
                if nearest <= 350 && nearest > 135 && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
	        self:ChaseEnemy()
	end
end