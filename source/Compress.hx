package;

using StringTools;

class Compress {
    function minify(text:String) {
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

    function optimizespritesheet(text:String) {
        var image:FlxSprite;
        //using awesome magic the variables above will appear finished (tiburones please help me finish this script)
        //btw instead of opening the xml just imagine it being the "text" variable from the function

        var box = [0, 0, 0, 0];
        var frames; //this will break but i need a variable
        for(frame in frames) {
            var width = frame.width;
            var height = frame.height;
            var coolx = frame.x;
            var cooly = frame.y;
            if((coolx + width) > box[2]) {
                box[2] = coolx + width;
            }
            if((cool3 + height) > box[2]) {
                box[3] = cool3 + height;
            }
        }
        //insert flxsprite cropping code
        return image;
    }
}
