class GladiatorGameInfo extends UDKGame;


var() const archetype GladiatorPawn PawnArchetype;

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
    local Pawn SpawnedPawn;

    if (NewPlayer == none || StartSpot == none)
    {
        return none;
    }

    SpawnedPawn = Spawn(PawnArchetype.Class,,, StartSpot.Location,, PawnArchetype);

    return SpawnedPawn;
}


DefaultProperties
{
    PawnArchetype=GladiatorPawn'GladiatorContent.Archetypes.GladiatorPawn'
    PlayerControllerClass=class'Gladiator.GladiatorPlayerController'
}