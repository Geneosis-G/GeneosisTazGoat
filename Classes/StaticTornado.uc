class StaticTornado extends Actor
	implements( GGExplosiveActorInterface );

var ParticleSystem mTornadoParticleTemplate;
var ParticleSystemComponent mTornadoParticle;

var AudioComponent mAC;
var SoundCue mTornadoCue;

var GGPawn myPawn;

/** If the bomb is already exploding it should not explode again */
var bool mIsExploding;

/** The momentum caused at an explosion */
var float mExplosiveMomentum;

/** The damage caused at an explosion */
var int mDamage;

/** The radius the explosion will affect */
var float mDamageRadius;

/** The damage type for the explosion */
var class< GGDamageTypeExplosiveActor > mDamageType;

/** The sound for the explosion */
var SoundCue mExplosionSound;

/** The particle effect for the explosion */
var ParticleSystem mExplosionEffectTemplate;

/** Class of ExplosionLight */
var class< UDKExplosionLight > mExplosionLightClass;

/** Where this actor is when it explodes */
var vector mExplosionLoc;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetPhysics(PHYS_None);
	CollisionComponent=none;
	mTornadoParticle = WorldInfo.MyEmitterPool.SpawnEmitter( mTornadoParticleTemplate, Location, Rotation, self);
	mTornadoParticle.SetHidden( true );
}

function AttachTo(GGPawn pawn)
{
	myPawn=pawn;
}

function ActivateTornado(bool activate)
{
	//WorldInfo.Game.Broadcast(self, "activate=" $ activate);

	if( mAC == none || mAC.IsPendingKill() )
	{
		mAC = CreateAudioComponent( mTornadoCue, false );
	}

	if(activate)
	{
		mAC.Play();
	}
	else
	{
		if( mAC.IsPlaying())
		{
			mAC.Stop();
		}
	}
	mTornadoParticle.SetHidden(!activate);
}

function ExplodeWithRadius(float radius)
{
	mDamageRadius=radius;
	Explode();
}

function Explode()
{
	if( mIsExploding || myPawn == none)
	{
		return;
	}

	mIsExploding = true;

	mExplosionLoc = Location;

	// Notify kismet and the game about the explosion
	TriggerEventClass( class'GGSeqEvent_Explosion', myPawn );
	//GGGameInfo( WorldInfo.Game ).OnExplosion( myPawn );

	HurtRadius( mDamage, mDamageRadius, mDamageType, mExplosiveMomentum, Location, myPawn, myPawn.Controller, true);

	mIsExploding = false;
}

function float GetDamageRadius()
{
	return mDamageRadius;
}

function vector GetExplosionLocation()
{
	return mExplosionLoc;
}

function int GetDamage()
{
	return mDamage;
}

function float GetExplosiveMomentum()
{
	return mExplosiveMomentum;
}

function Actor GetInstigator()
{
	return myPawn;
}

DefaultProperties
{
	bNoDelete=false
	bStatic=false
	bIgnoreBaseRotation=true
	mTornadoParticleTemplate=ParticleSystem'Goat_Effects.Effects.Effects_Tornado_01'
	mTornadoCue=SoundCue'Goat_Sound_Ambience_01.Cue.SummoningCircle_Cue'

	mExplosiveMomentum=50000.0f
	mDamage=100
	mDamageRadius=20.0f
	mDamageType=class'GGDamageTypeTornado'

	mExplosionSound=none
	mExplosionEffectTemplate=none
	mExplosionLightClass=none
}