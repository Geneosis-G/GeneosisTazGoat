class TazGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;
var bool isSpinning;
var float spinningSpeed;
var StaticTornado torn;
var SoundCue tazBaaSoundCue;
var float minDist;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		gMe.mBaaSoundCue=tazBaaSoundCue;
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(PCOwner != gMe.Controller)
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		if(localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ))
		{
			if(gMe.mIsRagdoll)
			{
				SetSpinning(!isSpinning);
			}
		}

		if(localInput.IsKeyIsPressed( "GBA_Jump", string( newKey ) ))
		{
			if(isSpinning && gMe.mDistanceToGround<minDist && gMe.Mesh.GetRBLinearVelocity().Z<100.f)
			{
				gMe.DoRagdollJump();
			}
		}
	}
}

function SetSpinning(bool spin)
{
	if(isSpinning == spin)
		return;

	isSpinning=spin;

	if(spin)
	{
		gMe.CustomTimeDilation*=spinningSpeed;
		gMe.mLayStill=true;
	}
	else
	{
		gMe.CustomTimeDilation/=spinningSpeed;
		gMe.mLayStill=false;
	}
	torn.ActivateTornado(spin);
}

event TickMutatorComponent( float deltaTime )
{
	local float r, h;

	super.TickMutatorComponent(deltaTime);

	gMe.GetBoundingCylinder( r, h );
	minDist=FMin(r, h)*2.f;

	if(torn == none)
	{
		torn=myMut.Spawn(class'StaticTornado');
		torn.AttachTo(gMe);
		torn.SetBase(gMe,, gMe.mesh, 'jetPackSocket');
	}

	if(!gMe.mIsRagdoll && isSpinning)
	{
		SetSpinning(false);
	}

	if(isSpinning)
	{
		DoHover();
		gMe.Mesh.SetRBAngularVelocity(vect(0.f, 0.f, 1.f), true);

		torn.ExplodeWithRadius(FMax(r, h));
	}
}

function DoHover()
{
	if(gMe.mDistanceToGround<minDist)
	{
		if(gMe.Mesh.GetRBLinearVelocity().Z<100.f)
		{
			gMe.Mesh.AddForce( vect(0, 0, 1) * 20.f * gMe.GetMass() );
		}
	}
}

defaultproperties
{
	spinningSpeed=6.f
	tazBaaSoundCue=SoundCue'TazSounds.TazTalkCue'
}