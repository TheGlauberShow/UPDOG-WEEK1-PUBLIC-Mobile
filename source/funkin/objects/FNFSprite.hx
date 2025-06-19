package funkin.objects;

import funkin.objects.*;
import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.Json;

typedef CrowdAnim =
{
	var time:Float;
	var data:Int;
	var length:Int;
	@:optional var mustHit:Bool;
	@:optional var type:String;
}

class FNFSprite extends FlxSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf'; // In case a character is missing, it will use BF on its place

	public var curCharacter:String = DEFAULT_CHARACTER;

	public var offsets:Map<String, Array<Float>> = [];
	public var holdTimer:Float = 0;
	public var stepsToHold:Float = 6.1; // dadVar
	public var canResetIdle:Bool = false;

	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;

	public var animationsArray:Array<Character.AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;
			else holdTimer = 0;

			canResetIdle = (holdTimer >= Conductor.stepCrotchet * 0.001 * stepsToHold)
				|| holdTimer == 0
				&& !animation.curAnim.name.startsWith('sing');
		}
		super.update(elapsed);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = offsets.get(AnimName);
		if (offsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		offsets[name] = [x, y];
	}

	public function loadFromJson(character:String, ?mod:Bool = false)
	{
		var json:Character.CharacterFile = getCharacterFile(character, mod);
		var spriteType = "sparrow";

		var charSpritePath = Paths.findAnyAsset('images/characters/' + json.image, ['.png', '.xml']);
		if (charSpritePath != null && mobile.backend.AssetUtils.assetExists(charSpritePath)) {
    		spriteType = "sparrow";
			// sprite (.png and .xml)
		}

		var txtAssetPath = Paths.findAsset('images/' + json.image + '.txt');
		if (txtAssetPath != null && mobile.backend.AssetUtils.assetExists(txtAssetPath))
			spriteType = "packer";

		/*var animAssetPath = Paths.findAsset('images/' + json.image + '/Animation.json');
		if (animAssetPath != null && mobile.backend.AssetUtils.assetExists(animAssetPath))
			spriteType = "texture";*/

		switch (spriteType)
		{
			case "packer":
				frames = Paths.getPackerAtlas(json.image);

			case "sparrow":
				frames = Paths.getSparrowAtlas(json.image);

			// case "texture":
			// 	frames = AtlasFrameMaker.construct(json.image);
		}
		imageFile = json.image;

		if (json.scale != 1)
		{
			jsonScale = json.scale;
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}

		flipX = !!json.flip_x;
		if (json.no_antialiasing)
		{
			antialiasing = false;
			noAntialiasing = true;
		}

		antialiasing = !noAntialiasing;
		if (!ClientPrefs.globalAntialiasing) antialiasing = false;

		animationsArray = json.animations;
		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop;
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0)
				{
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}
				else
				{
					animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}

				if (anim.offsets != null && anim.offsets.length > 1)
				{
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}
			}
		}
	}

	public function getCharacterFile(character:String, ?mod:Bool = false)
	{
		var characterPath:String = 'characters/' + character + '.json';
		var rawJson:Dynamic = null;
		var assetPath = Paths.findAsset(characterPath);

		var charSpritePath = Paths.findAnyAsset(characterPath, [".png", ".xml"]);
		if (charSpritePath != null && mobile.backend.AssetUtils.assetExists(charSpritePath)) {
    		rawJson = mobile.backend.AssetUtils.getText(assetPath);
		}

		if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
			rawJson = mobile.backend.AssetUtils.getText(assetPath);
		}

		if (rawJson == null) {
			var defaultPath = Paths.findAsset('characters/' + DEFAULT_CHARACTER + '.json');
			if (defaultPath != null && mobile.backend.AssetUtils.assetExists(defaultPath)) {
				rawJson = mobile.backend.AssetUtils.getText(defaultPath);
			}
		}

		return cast Json.parse(rawJson);
	}
}
