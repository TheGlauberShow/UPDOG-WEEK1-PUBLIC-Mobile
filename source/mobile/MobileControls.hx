package mobile;

import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class MobileControls extends FlxSpriteGroup {
	public var buttons:Map<String, FlxButton> = [];
	var layout:Array<String>;

	public function new(useDpad:Bool = true, actionButtons:Array<String>) {
		super();
		layout = [];
		var atlas = FlxAtlasFrames.fromSpriteSheetPacker(
			Paths.image("mobileControls/virtualpad"),
			Paths.file("images/mobileControls/virtualpad.txt")
		);

		if (useDpad) {
			layout.push("up", "down", "left", "right");
		}
		layout = layout.concat(actionButtons);

		var spacing = 132;
		for (i in 0...layout.length) {
			var id = layout[i];
			var x = (FlxG.width - spacing * layout.length) + spacing * i;
			var y = FlxG.height - 140;
			if (id == "up") { x = 100; y = FlxG.height - 230; }
			if (id == "down") { x = 100; y = FlxG.height - 100; }
			if (id == "left") { x = 30; y = FlxG.height - 165; }
			if (id == "right") { x = 170; y = FlxG.height - 165; }

			var btn = makeButton(id, x, y, atlas);
			buttons.set(id, btn);
			add(btn);
		}
	}

	function makeButton(name:String, x:Float, y:Float, frames:FlxAtlasFrames):FlxButton {
		var btn = new FlxButton(x, y);
		btn.frames = frames;
		btn.animation.frameName = name;
		btn.resetSizeFromFrame();
		btn.scrollFactor.set();
		btn.alpha = 0.6;
		btn.immovable = true;
		return btn;
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

	public function updateControlsToEngine():Void {
		if (justPressed(\"a\")) Controls.instance.ACCEPT.trigger();
		if (justPressed(\"b\")) Controls.instance.BACK.trigger();
		if (justPressed(\"left\")) Controls.instance.UI_LEFT.trigger();
		if (justPressed(\"right\")) Controls.instance.UI_RIGHT.trigger();
		if (justPressed(\"up\")) Controls.instance.UI_UP.trigger();
		if (justPressed(\"down\")) Controls.instance.UI_DOWN.trigger();
	}
}