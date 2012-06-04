class MeleeWeapon extends Weapon;

var() const name SwordHiltSocketName;
var() const name SwordTipSocketName;

var array<Actor> SwingHitActors;
var array<int> Swings;
var const int MaxSwings;

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
    local GladiatorPawn MWPawn;

    super.ClientGivenTo(NewOwner, bDoNotActivate);

    MWPawn =GladiatorPawn(NewOwner);

    if (MWPawn != none && MWPawn.Mesh.GetSocketByName(MWPawn.SwordHandSocketName) != none)
    {
        Mesh.SetShadowParent(MWPawn.Mesh);
        Mesh.SetLightEnvironment(MWPawn.LightEnvironment);
        MWPawn.Mesh.AttachComponentToSocket(Mesh, MWPawn.SwordHandSocketName);
   }
}

function RestoreAmmo(int Amount, optional byte FireModeNum)
{
   Swings[FireModeNum] = Min(Amount, MaxSwings);
}

function ConsumeAmmo(byte FireModeNum)
{
   if (HasAmmo(FireModeNum))
   {
      Swings[FireModeNum]--;
   }
}

simulated function bool HasAmmo(byte FireModeNum, optional int Ammount)
{
   return Swings[FireModeNum] > Ammount;
}

simulated function FireAmmunition()
{
   StopFire(CurrentFireMode);
   SwingHitActors.Remove(0, SwingHitActors.Length);

   if (HasAmmo(CurrentFireMode))
   {
      super.FireAmmunition();
   }
   GladiatorPawn(Owner).SwingAnim.PlayCustomAnim('Glad_Attack', 1.0);
}
function Vector GetSwordSocketLocation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SwordRotation;
   local SkeletalMeshComponent SMC;

   SMC = SkeletalMeshComponent(Mesh);

   if (SMC != none && SMC.GetSocketByName(SocketName) != none)
   {
      SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
   }

   return SocketLocation;
}

function bool AddToSwingHitActors(Actor HitActor)
{
   local int i;

   for (i = 0; i < SwingHitActors.Length; i++)
   {
      if (SwingHitActors[i] == HitActor)
      {
         return false;
      }
   }

   SwingHitActors.AddItem(HitActor);
   return true;
}

function TraceSwing()
{
   local Actor HitActor;
   local Vector HitLoc, HitNorm, SwordTip, SwordHilt, Momentum;
   local int DamageAmount;

   SwordTip = GetSwordSocketLocation(SwordTipSocketName);
   SwordHilt = GetSwordSocketLocation(SwordHiltSocketName);
   DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);

   foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, SwordTip, SwordHilt)
   {
      if (HitActor != self && AddToSwingHitActors(HitActor))
      {
         Momentum = Normal(SwordTip - SwordHilt) * InstantHitMomentum[CurrentFireMode];
         HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
      }
   }
}
simulated state Swinging extends WeaponFiring
{
   simulated event Tick(float DeltaTime)
   {
      super.Tick(DeltaTime);
      TraceSwing();
   }

   simulated event EndState(Name NextStateName)
   {
      super.EndState(NextStateName);
      SetTimer(GetFireInterval(CurrentFireMode), false, nameof(ResetSwings));
   }
}

function ResetSwings()
{
   RestoreAmmo(MaxSwings);
}
DefaultProperties
{
	MaxSwings=2
	Swings(0)=2
	bMeleeWeapon=true;
	bInstantHit=true;
	bCanThrow=false;
	FiringStatesArray(0)="Swinging"

	WeaponFireTypes(0)=EWFT_Custom
    Begin Object Class=SkeletalMeshComponent Name=SwordSkeletalMeshComponent
       bCacheAnimSequenceNodes=false
       AlwaysLoadOnClient=true
       AlwaysLoadOnServer=true
       CastShadow=true
       BlockRigidBody=true
       bUpdateSkelWhenNotRendered=false
       bIgnoreControllersWhenNotRendered=true
       bUpdateKinematicBonesFromAnimation=true
       bCastDynamicShadow=true
       RBChannel=RBCC_Untitled3
       RBCollideWithChannels=(Untitled3=true)
       bOverrideAttachmentOwnerVisibility=true
       bAcceptsDynamicDecals=false
       bHasPhysicsAssetInstance=true
       TickGroup=TG_PreAsyncWork
       MinDistFactorForKinematicUpdate=0.2f
       bChartDistanceFactor=true
       RBDominanceGroup=20
       Scale=1.f
       bAllowAmbientOcclusion=false
       bUseOnePassLightingOnTranslucency=true
       bPerBoneMotionBlur=true
    End Object
    Mesh=SwordSkeletalMeshComponent
}