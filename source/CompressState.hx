package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.util.FlxTimer;

using StringTools;

class CompressState extends FlxState {
    //ui
	var bgcolor = 0xFF757575;
    var text:FlxText;
    var fontsize = 26;
	var bordersize = 2;
    var defaulttext = 'Compressing...\nplease do not tab out';

    //bools
    var compressing = false;
    var error = false;

	override public function create() {
		FlxG.cameras.bgColor = bgcolor; //set bg color

        text = new FlxText(0, 0, FlxG.width - 20, defaulttext, fontsize);
		text.setFormat(Paths.returnfont('vcr.ttf'), fontsize, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		text.borderSize = bordersize;
        text.screenCenter();
		add(text);

		super.create();
        
        new FlxTimer().start(0.5, loadthecompresser, 1); //so the text can load
	}

    function loadthecompresser(timer:FlxTimer) {
        if(error) {
            text.text = Compress.execute(true);
        } else {
            text.text = Compress.execute();
        }
        if(text.text.contains('error')) {
            error = true;
        }
        text.screenCenter();
        compressing = false;
    }

	override public function update(elapsed:Float) {
        if(!compressing) {
            if(FlxG.keys.justPressed.ESCAPE) {
                FlxG.switchState(new MainState());
            }
            if(error) {
                if(FlxG.keys.justPressed.ENTER) {
                    text.text = defaulttext;
                    text.screenCenter();
                    new FlxTimer().start(0.5, loadthecompresser, 1); //so the text can load
                    compressing = true;
                }
            }   
        }

		super.update(elapsed);
	}
}
