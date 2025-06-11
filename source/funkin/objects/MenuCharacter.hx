package funkin.objects;

import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;

typedef MenuCharacterFile =
{
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
	var flipX:Bool;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var hasConfirmAnimation:Bool = false;

	private static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf')
	{
		if (character == null) character = '';
		if (character == this.character) return;

		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		hasConfirmAnimation = false;
		switch (character)
		{
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var characterPath:String = 'images/menucharacters/' + character + '.json';
				var rawJson = null;
				var assetPath = Paths.findAsset(characterPath);

				#if sys
				if (assetPath != null && sys.FileSystem.exists(assetPath)) {
					rawJson = sys.io.File.getContent(assetPath);
				} else
				#end
				if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
					rawJson = mobile.backend.AssetUtils.getAssetContent(assetPath);
				}

				if (rawJson == null) {
					var defaultPath = Paths.findAsset('images/menucharacters/' + DEFAULT_CHARACTER + '.json');
					#if sys
					if (defaultPath != null && sys.FileSystem.exists(defaultPath)) {
						rawJson = sys.io.File.getContent(defaultPath);
					} else
					#end
					if (defaultPath != null && mobile.backend.AssetUtils.assetExists(defaultPath)) {
						rawJson = mobile.backend.AssetUtils.getAssetContent(defaultPath);
					}
				}

				var charFile:MenuCharacterFile = cast Json.parse(rawJson);
				frames = Paths.getSparrowAtlas('menucharacters/' + charFile.image);
				animation.addByPrefix('idle', charFile.idle_anim, 24);

				var confirmAnim:String = charFile.confirm_anim;
				if (confirmAnim != null && confirmAnim != charFile.idle_anim)
				{
					animation.addByPrefix('confirm', confirmAnim, 24, false);
					if (animation.getByName('confirm') != null) // check for invalid animation
						hasConfirmAnimation = true;
				}

				flipX = (charFile.flipX == true);

				if (charFile.scale != 1)
				{
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}
				offset.set(charFile.position[0], charFile.position[1]);
				animation.play('idle');
		}
	}
}
