/* 
Copyright (c) 2011 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

namespace GnomePie {

/////////////////////////////////////////////////////////////////////////    
///  
/////////////////////////////////////////////////////////////////////////

public class Icon : Image {

    /////////////////////////////////////////////////////////////////////
    /// A cache which stores images loaded from files. The key is in form
    /// <filename>@<size>
    /////////////////////////////////////////////////////////////////////

    private static Gee.HashMap<string, Cairo.ImageSurface?> cache { private get; private set; }
    
    
    /////////////////////////////////////////////////////////////////////
    /// Initializes the cache.
    /////////////////////////////////////////////////////////////////////
    
    static construct {
        clear_cache();
        
        Gtk.IconTheme.get_default().changed.connect(() => {
            clear_cache();
        });
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Clears the cache.
    /////////////////////////////////////////////////////////////////////
    
    static void clear_cache() {
        cache = new Gee.HashMap<string, Cairo.ImageSurface?>();
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Loads an icon from the current icon theme of the user.
    /////////////////////////////////////////////////////////////////////
    
    public Icon(string icon_name, int size) {
        var cached = this.cache.get("%s@%u".printf(icon_name, size));
        
        if (cached == null) {
            base.from_file_at_size(this.get_icon_file(icon_name, size), size, size);
            this.cache.set("%s@%u".printf(icon_name, size), this.surface);
        } else {
            this.surface = cached;
        }
    }
    
    public int size() {
        return base.width();
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Returns the filename for a given system icon.
    /////////////////////////////////////////////////////////////////////
    
    private string get_icon_file(string icon_name, int size) {
        string result = "";
    
        if (!icon_name.contains("/")) {
            var icon_theme = Gtk.IconTheme.get_default();
            var file = icon_theme.lookup_icon(icon_name, size, 0);
            if (file != null) result = file.get_filename();
        } else {
            result = icon_name;
        }
        
        if (result == "") {
            warning("Icon \"" + icon_name + "\" not found! Using default icon...");
            icon_name = "application-default-icon";
            var icon_theme = Gtk.IconTheme.get_default();
            var file = icon_theme.lookup_icon(icon_name, size, 0);
            if (file != null) result = file.get_filename();
        }
        
        if (result == "")
            warning("Icon \"" + icon_name + "\" not found! Will be ugly...");
            
        return result;
    }
}

}
