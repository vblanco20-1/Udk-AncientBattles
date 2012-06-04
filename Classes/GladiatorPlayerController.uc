class GladiatorPlayerController extends UDKPlayerController;

function UpdateRotation(float DeltaTime)
{
    local GladiatorPawn MWPawn;

    super.UpdateRotation(DeltaTime);

    MWPawn = GladiatorPawn(self.Pawn);

    if (MWPawn != none)
    {
        MWPawn.CamPitch = Clamp(MWPawn.CamPitch + self.PlayerInput.aLookUp, -MWPawn.IsoCamAngle, MWPawn.IsoCamAngle);
    }
}


DefaultProperties
{
}