package funkin.states.editors;

import funkin.states.ChartingState;
import openfl.utils.Assets;

class ChartingOptionsSubmenu extends ChartingState
{
    public function new()
    {
        super();
        //this.name = "Charting Options";
        //this.icon = "assets/icons/charting_options.png";
        //this.description = "Configure charting options for your project.";
    }

    override public function onEnter():Void
    {
        super.onEnter();
        // Additional setup for the Charting Options submenu
    }

    override public function onExit():Void
    {
        super.onExit();
        // Cleanup if necessary
    }
}