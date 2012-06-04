class GladiatorPawn extends Pawn;

var() const DynamicLightEnvironmentComponent LightEnvironment;
var() const int IsoCamAngle;
var() const float CamOffsetDistance;
var() const Name SwordHandSocketName;
var() const archetype MeleeWeapon SwordArchetype;
var AnimNodePlayCustomAnim SwingAnim;
var float CamPitch;


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        SwingAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('SwingCustomAnim'));
    }
}


simulated function bool CalcCamera(float DeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{
    local Vector HitLocation, HitNormal;

    out_CamLoc = Location;
    out_CamLoc.X -= Cos(Rotation.Yaw * UnrRotToRad) * Cos(CamPitch * UnrRotToRad) * CamOffsetDistance;
    out_CamLoc.Y -= Sin(Rotation.Yaw * UnrRotToRad) * Cos(CamPitch * UnrRotToRad) * CamOffsetDistance;
    out_CamLoc.Z -= Sin(CamPitch * UnrRotToRad) * CamOffsetDistance;

    out_CamRot.Yaw = Rotation.Yaw;
    out_CamRot.Pitch = CamPitch;
    out_CamRot.Roll = 0;

    if (Trace(HitLocation, HitNormal, out_CamLoc, Location, false, vect(12, 12, 12)) != none)
    {
        out_CamLoc = HitLocation;
    }

    return true;
}

event AddDefaultInventory()
{
    local GladiatorInventory MWInventoryManager;

    super.AddDefaultInventory();

    if (SwordArchetype != None)
    {
        MWInventoryManager = GladiatorInventory(self.InvManager);

        if (MWInventoryManager != None)
        {
            MWInventoryManager.CreateInventoryArchetype(SwordArchetype, false);
        }
    }
}


DefaultProperties
{
	
	InventoryManagerClass=class'GladiatorInventory'
    Components.Remove(Sprite)
	SwordArchetype=MeleeWeapon'GladiatorContent.Archetypes.MeleeWeaponSword'
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
       bSynthesizeSHLight=true
       bIsCharacterLightEnvironment=true
       bUseBooleanEnvironmentShadowing=false
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

    Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
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
       LightEnvironment=MyLightEnvironment
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
    Mesh=MySkeletalMeshComponent
    Components.Add(MySkeletalMeshComponent)
}