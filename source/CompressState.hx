package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

using StringTools;

class CompressState extends FlxState {
    //ui
	var bgcolor = 0xFF757575;
    var text:FlxText;
    var fontsize = 26;
	var bordersize = 2;

	override public function create() {
		FlxG.cameras.bgColor = bgcolor; //set bg color

        text = new FlxText(0, 0, FlxG.width - 20, 'Compressing...\nplease do not tab out', fontsize);
		text.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		text.borderSize = bordersize;
        text.screenCenter();
		add(text);

        text.text = Compress.execute();
        text.screenCenter();

		super.create();
	}

	override public function update(elapsed:Float) {
        if(FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new State());
		}

		super.update(elapsed);
	}
}
