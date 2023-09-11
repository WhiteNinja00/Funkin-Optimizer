package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxState;

using StringTools;

class Compress {
    public static function execute(skip:Bool = false) {
        var defaultfoldername = 'assetsoptimized'; //if you wanna change the name of the exported folder change this!!
        if(FileSystem.exists('./' + defaultfoldername + '/') && !skip) {
            return 'errorare you sure you want to continue without deleting the "' + defaultfoldername + '" folder?\npress ENTER to continue\n press ESC to return';
        }
        FileSystem.createDirectory('./$defaultfoldername/');
        //checkfolders('assets/', defaultfoldername);
        Sys.command('Xcopy assets ' + defaultfoldername + ' /H /C /I /S /D');
        checkfiles('assets/', defaultfoldername);
        return 'optimization complete\npress ESC to return';
    }

    /*
    public static function checkfolders(directory:String, folder:String) {
        if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (sys.FileSystem.isDirectory(path)) {
					var cooldirectory = haxe.io.Path.addTrailingSlash(path);
                    Sys.command('Xcopy ' + cooldirectory + ' ' + cooldirectory.replace('assets', folder));
                    checkfiles(cooldirectory, folder);
				}
			}
		}
    }
    */

    public static function checkfiles(directory:String, folder:String) {
        if(sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				if (!sys.FileSystem.isDirectory(path)) {
                    if(path.endsWith('.xml')) {
                        if(Variables.shinksprsh) {
                            cropsheet(path);
                        }
                        if(Variables.minxml) {
                            sys.io.File.saveContent(path.replace('assets', folder), minify(sys.io.File.getContent(path)));
                        }
                    } else if(path.endsWith('.lua')) {
                        if(Variables.minlua) {
                            sys.io.File.saveContent(path.replace('assets', folder), minify(sys.io.File.getContent(path)));
                        }
                    }
				} else {
					var cooldirectory = haxe.io.Path.addTrailingSlash(path);
					checkfiles(cooldirectory, folder);
				}
			}
		}
    }

    public static function minify(text:String) {
        var splittext:Array<String> = text.split('\n');
        var finalstring = '';
        for(i in 0...splittext.length) {
            var thing = splittext[i];
            if(!(thing.startsWith('//') || thing.startsWith('--') || thing.startsWith('<!-- '))) {
                finalstring += (' ' + thing).replace('	', '');
            }
        }
        return finalstring;
    }

    public static function cropsheet(path:String) {
        var spritesheet = new FlxSprite().frames = FlxAtlasFrames.fromSparrow(path.replace('.xml', '.png'), sys.io.File.getContent(path));
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
