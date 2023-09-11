package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxState;

using StringTools;

class Compress {
    public static function execute() {
        var defaultfoldername = 'assetsoptimized'; //if you wanna change the name of the exported folder change this!!
        if(FileSystem.exists('./' + defaultfoldername + '/')) {
            return 'error\nplease delete the\n"' + defaultfoldername + '" folder before optimizing\npress esc to return';
        }
        FileSystem.createDirectory('./$defaultfoldername/');
        Sys.command('Xcopy assets ' + defaultfoldername);
        checkfiles('assets/', defaultfoldername);
        return 'optimization complete\npress esc to return';
    }

    public static function checkfiles(directory:String, folder:String) {
        if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path)) {
                    if(path.endsWith('.xml')) {
                        if(Variables.shinksprsh) {
                            cropsheet(path);
                        }
                    } else if(path.endsWith('.lua')) {
                        if(Variables.minlua) {
                            sys.io.File.saveContent(path.replace('assets', folder), minify(Assets.getText(path)));
                        }
                    }
				} else {
					var directory = haxe.io.Path.addTrailingSlash(path);
					checkfiles('', folder);
				}
			}
		}
    }

    public static function minify(text:String) {
        var splittext:Array<String> = text.split('\n');
        var finalstring = '';
        for(i in 0...splittext.length) {
            var thing = splittext[i];
            if(!(thing.startsWith('//') || thing.startsWith('--'))) {
                finalstring += ' ' + thing;
            }
        }
        return finalstring;
    }

    public static function cropsheet(path:String) {
        var spritesheet = new FlxSprite().frames = FlxAtlasFrames.fromSparrow(path.replace('.xml', '.png'), Assets.getText(path));
        var image = new FlxSprite();
        var box = [0.0, 0.0];
        for(f in spritesheet.frames) {
            if(f.frame.right > box[0]) {
                box[0] = f.frame.right;
            }
            if(f.frame.bottom > box[1]) {
                box[1] = f.frame.bottom;
            }
        }
        var boxclip = new FlxRect(0, 0, box[0], box[1]);
        image.clipRect = boxclip;
        return image;
    }
}
