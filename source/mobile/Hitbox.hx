package mobile;

import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BitmapData;
import openfl.display.Shape;

class Hitbox extends FlxSpriteGroup {
	public var buttons:Map<String, FlxButton> = [];
	public var hints:FlxSpriteGroup;

	var layout:Array<String> = ["left", "down", "up", "right"];
	var colors:Array<Int> = [0xFFE390E6, 0x00EDFF, 0x00FF00, 0xFFFF0000];

	public function new() {
		super();
		hints = new FlxSpriteGroup();
		add(hints);

		var screenW = FlxG.width;
		var btnW = Std.int(screenW / layout.length);

		for (i in 0...layout.length) {
			var name = layout[i];
			var btn = makeButton(i * btnW, 0, btnW, FlxG.height, colors[i]);
			buttons.set(name, btn);
			add(btn);

			if (ClientPrefs.ExtraHints && !ClientPrefs.hideHitboxHints) {
				var hint = makeHint(i * btnW, 0, btnW, FlxG.height, colors[i]);
				hints.add(hint);
			}
		}
	}

	function makeButton(x:Float, y:Float, w:Int, h:Int, color:Int):FlxButton {
		var btn = new FlxButton(x, y);
		btn.makeGraphic(w, h, FlxColor.TRANSPARENT);
		btn.updateHitbox();
		btn.alpha = 0.00001;

		var tween:FlxTween = null;
		btn.onDown.callback = function() {
			if (tween != null) tween.cancel();
			tween = FlxTween.tween(btn, {alpha: ClientPrefs.controlsAlpha}, 0.1, {ease: FlxEase.quadOut});
		}
		btn.onUp.callback = function() {
			if (tween != null) tween.cancel();
			tween = FlxTween.tween(btn, {alpha: 0.00001}, 0.1, {ease: FlxEase.quadIn});
		}
		btn.onOut.callback = function() {
			if (tween != null) tween.cancel();
			tween = FlxTween.tween(btn, {alpha: 0.00001}, 0.1, {ease: FlxEase.quadIn});
		}

		return btn;
	}

	function makeHint(x:Float, y:Float, w:Int, h:Int, color:Int):FlxSprite {
		var shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.lineStyle(2, 0xFFFFFF);
		shape.graphics.drawRect(0, 0, w, h);
		shape.graphics.beginFill(color);
		shape.graphics.drawRect(4, 4, w - 8, h - 8);
		shape.graphics.endFill();

		var bmp = new BitmapData(w, h, true, 0);
		bmp.draw(shape);
		var sprite = new FlxSprite(x, y, bmp);
		return sprite;
	}

	public function pressed(name:String):Bool {
		return buttons.exists(name) && buttons.get(name).pressed;
	}
	public function justPressed(name:String):Bool {
		return buttons.exists(name) && buttons.get(name).justPressed;
	}
	public function justReleased(name:String):Bool {
		return buttons.exists(name) && buttons.get(name).justReleased;
	}
}