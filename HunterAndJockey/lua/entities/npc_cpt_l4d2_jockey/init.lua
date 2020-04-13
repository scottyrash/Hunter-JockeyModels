if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/infected/jockey.mdl"}
ENT.StartHealth = 250
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
	["Attack"] = {"cptges_Jockey_Melee"},
        ["RangeAttack"] = {ACT_JUMP},
}

ENT.tbl_Sounds = {
	["Alert"] = {
            "cpt_l4d2/jockey/voice/alert/jockey_02.wav",
            "cpt_l4d2/jockey/voice/alert/jockey_04.wav",
        },
        ["RangeAttack"] = {
            "cpt_l4d2/jockey/voice/attack/jockey_loudattack01.wav",
        },
        ["Death"] = {
            "cpt_l4d2/jockey/voice/death/jockey_death01.wav",
            "cpt_l4d2/jockey/voice/death/jockey_death02.wav",
            "cpt_l4d2/jockey/voice/death/jockey_death03.wav",
            "cpt_l4d2/jockey/voice/death/jockey_death04.wav", 
            "cpt_l4d2/jockey/voice/death/jockey_death05.wav", 
            "cpt_l4d2/jockey/voice/death/jockey_death06.wav",
        },
        ["Idle"] = {
            "cpt_l4d2/jockey/voice/idle/jockey_lurk01.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk03.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk04.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk05.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk06.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk07.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk09.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_lurk11.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize02.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize06.wav", 
            "cpt_l4d2/jockey/voice/idle/jockey_recognize07.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize08.wav", 
            "cpt_l4d2/jockey/voice/idle/jockey_recognize09.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize10.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize11.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize12.wav", 
            "cpt_l4d2/jockey/voice/idle/jockey_recognize13.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize15.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize17.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize18.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize19.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize20.wav",
            "cpt_l4d2/jockey/voice/idle/jockey_recognize24.wav",
            "bacteria/jockeybacteria.wav",
            "bacteria/jockeybacterias.wav",
        },
        ["Pain"] = {
            "cpt_l4d2/jockey/voice/pain/jockey_pain01.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain02.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain03.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain04.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain05.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain06.wav", 
            "cpt_l4d2/jockey/voice/pain/jockey_pain07.wav",
            "cpt_l4d2/jockey/voice/pain/jockey_pain08.wav",
        },
        ["Bacteria"] = {
            "bacteria/jockeybacteria.wav",
            "bacteria/jockeybacterias.wav",
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
	self:SetHullType(HULL_WIDE_SHORT)
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
		if arg1 == "right" then
                        self:PlaySound("Attack")

			self:DoDamage(self.MeleeAttackDamageDistance *1.5,self.MeleeAttackDamage,self.MeleeAttackType)
		else
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
                end     
		return true
	end
	if(event == "emit") then
		if arg1 == "Idle" then
			self:PlaySound("Idle",95,95,105,true)
		end
                if arg1 == "Alert" then
			self:PlaySound("Alert",95,95,105,true)
		end 
                if arg1 == "Pain" then
			self:PlaySound("Pain",95,95,105,true)
		end
                if arg1 == "Attack" then
			self:PlaySound("Attack",95,95,105,true)
		end 
                if arg1 == "Hit" then
			self:PlaySound("Hit",95,95,105,true)
		end
                if arg1 == "Death" then
			self:PlaySound("Death",95,95,105,true)
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