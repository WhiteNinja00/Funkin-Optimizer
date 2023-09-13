package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxState;
import openfl.geom.Rectangle;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import sys.io.FileOutput;

using StringTools;

class Compress {
    public static function execute(skip:Bool = false) {
        var defaultfoldername = 'assetsoptimized'; //if you wanna change the name of the exported folder change this!! and do NOT change it to "assets"
        if(FileSystem.exists('./' + defaultfoldername + '/') && !skip) {
            return 'error\nare you sure you want to continue without deleting the "' + defaultfoldername + '" folder?\npress ENTER to continue\n press ESC to return';
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
                    if(path.endsWith('.png')) {
                        if(Variables.jpegcomp) {
                            savepng(jpegcompress(path).pixels, path);
                        }
                    } else if(path.endsWith('.xml')) {
                        if(Variables.shinksprsh) {
                            savepng(cropsheet(path).pixels, path);
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
        var splittext:Array<String> = text.toString().split('\n');
        var cleanedtext:Array<String> = [];
        for(word in splittext) {
            var start = false;
            var wordstring = '';
            for(letter in word.split('')) {
                if(!start) {
                    if(letter != ' ' && letter != '	') {
                        start = true;
                    }
                }
                if(start) {
                    wordstring += letter;
                }
            }
            if(!wordstring.startsWith('//') && !wordstring.startsWith('--') && !wordstring.startsWith('<!--') && wordstring != '') {
                cleanedtext.push(wordstring);
            }
        }
        var finalstring = '';
        for(word in cleanedtext) {
            finalstring += word;
        }
        return finalstring;
    }

    public static function cropsheet(path:String):FlxSprite {
        var imagepath = path.replace('.xml', '.png');
        var spritesheet = new FlxSprite();
        spritesheet.frames = FlxAtlasFrames.fromSparrow(imagepath, sys.io.File.getContent(path));
        var image = new FlxSprite().loadGraphic(imagepath);
        var box = [0.0, 0.0];
        trace(sys.io.File.getContent(path));
        trace(spritesheet);
        trace(spritesheet.width);
        trace(imagepath);
        trace(FlxAtlasFrames.fromSparrow(imagepath, sys.io.File.getContent(path)));
        trace(spritesheet.frames);
        /*
        for(f in spritesheet.frames) { //it crashes here?
            if(f.frame.right > box[0]) {
                box[0] = f.frame.right;
            }
            if(f.frame.bottom > box[1]) {
                box[1] = f.frame.bottom;
            }
        }
        */
        var boxclip = new FlxRect(0, 0, box[0], box[1]);
        image.clipRect = boxclip;
        return image;
    }

    public static function jpegcompress(path:String):FlxSprite {
        var image = new FlxSprite().loadGraphic(path);
        trace(image.pixels.encode(new Rectangle(0, 0, image.width, image.height), new openfl.display.JPEGEncoderOptions()));
        return image;
    }

    public static function savepng(bitdata:BitmapData, path:String) {
        var imageData:ByteArray = bitdata.encode(new Rectangle(), PNGEncoderOptions);
        var output:FileOutput = sys.io.File.write(path, true);
        output.writeBytes(imageData, 0, imageData.length);
        output.close();
    }
}
