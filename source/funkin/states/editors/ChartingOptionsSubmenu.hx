package funkin.states.editors;

import flixel.FlxSubState;
import flixel.group.FlxTypedGroup;
import funkin.objects.Alphabet;

class ChartingOptionsSubmenu extends FlxSubState
{
    var grpMenuShit:FlxTypedGroup<Alphabet>;
    var menuItems:Array<String> = [
        'Resume',
        'Play from beginning',
        'Play from here',
        'Set start time',
        'Play from start time'
        // ...
    ];
    var curSelected:Int = 0;

    public function new()
    {
        super();
    }
}