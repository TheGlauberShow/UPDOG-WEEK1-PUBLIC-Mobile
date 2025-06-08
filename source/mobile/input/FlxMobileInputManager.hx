package mobile.input;

class FlxMobileInputManager {
	public static function mapInput(name:String):FlxMobileInputID {
		return switch(name.toLowerCase()) {
			case "a": FlxMobileInputID.A;
			case "b": FlxMobileInputID.B;
			case "x": FlxMobileInputID.X;
			case "y": FlxMobileInputID.Y;
			case "up": FlxMobileInputID.UP;
			case "down": FlxMobileInputID.DOWN;
			case "left": FlxMobileInputID.LEFT;
			case "right": FlxMobileInputID.RIGHT;
			default: FlxMobileInputID.NONE;
		}
	}
}