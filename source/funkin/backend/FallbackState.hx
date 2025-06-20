package funkin.backend;

class FallbackState extends MusicBeatState
{
    var warningMessage:String;
    var continueCallback:Void->Void;

    public function new(warningMessage:String,continueCallback:Void->Void)
    {
        this.continueCallback = continueCallback;
        this.warningMessage = warningMessage;
        super();
    }

    override function create()
    {
        var bg = new FlxSprite().loadGraphic(Paths.image('uhoh'));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        add(bg);

        var error = new FlxText(0,0,0,'ERROR',46);
		error.setFormat(Paths.font('vcr'), 46, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
        error.screenCenter(X);
        error.y = 25;
        add(error);
        FlxTween.tween(error,{y: error.y + 45},2, {ease: FlxEase.sineInOut,type: PINGPONG});

        var text = new FlxText(25,0,FlxG.width - 50,warningMessage,32);
		text.setFormat(Paths.font('vcr'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(text);
        text.screenCenter(Y);

        var text = new FlxText(0,FlxG.height - 25 - 32,FlxG.width,'Press "A" button to continue.',32);
		text.setFormat(Paths.font('vcr'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        add(text);

        super.create();
        #if mobile
		addVirtualPad(NONE,A); // Just the A button
		#end
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        // fix on mobile
        if (controls.ACCEPT #if mobile || _virtualpad.buttonA.justPressed #end) 
        {
            persistentUpdate = false;
            // continueCallback(); // Commented for now, as it is not used in the original code
            FlxG.sound.play(Paths.sound('confirmMenu'), 1); // Play confirmation sound
            FlxG.switchState(new TitleState()); // Switch to title state
        }
    }
}