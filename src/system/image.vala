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
/// A class which loads image files. It can load image files in various
/// formats, including jpeg, png and svg. 
/////////////////////////////////////////////////////////////////////////

public class Image : GLib.Object {
    
    /////////////////////////////////////////////////////////////////////
    /// The internally used surface.
    /////////////////////////////////////////////////////////////////////
    
    public Cairo.ImageSurface surface { public get; protected set; default=null; }
    
    
    /////////////////////////////////////////////////////////////////////
    /// Creates an empty Image.
    /////////////////////////////////////////////////////////////////////
    
    public Image.empty(int width, int height, Color? color = null) {
        this.surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, width, height);
        
        if (color != null) {
            var ctx = this.context();
            ctx.set_source_rgb(color.r, color.g, color.b);
            ctx.paint();
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Loads an icon from the the given filename.
    /////////////////////////////////////////////////////////////////////
    
    public Image.from_file(string filename) {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file(filename);
            
            if (pixbuf != null) {
                this.from_pixbuf(pixbuf);
            } else {
                warning("Failed to load " + filename + "!");
            }
        } catch (GLib.Error e) {
            message("Error loading image file: %s", e.message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Loads an icon from the the given filename at a given size.
    /////////////////////////////////////////////////////////////////////
    
    public Image.from_file_at_size(string filename, int width, int height) {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file_at_size(filename, width, height);
            
            if (pixbuf != null) {
                this.from_pixbuf(pixbuf);
            } else {
                warning("Failed to load " + filename + "!");
            }
        } catch (GLib.Error e) {
            message("Error loading image file: %s", e.message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Loads an icon from the the given Gdk.Pixbuf.
    /////////////////////////////////////////////////////////////////////
    
    public Image.from_pixbuf(Gdk.Pixbuf pixbuf) {
        this.surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, pixbuf.width, pixbuf.height);
    
        var ctx = this.context();
        Gdk.cairo_set_source_pixbuf(ctx, pixbuf, 1.0, 1.0);
        ctx.paint();
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Paints the image onto the given Cairo.Context
    /////////////////////////////////////////////////////////////////////
    
    public void paint_on(Cairo.Context ctx, double alpha = 1.0) {
        ctx.set_source_surface(this.surface, -0.5*this.width()-1, -0.5*this.height()-1);
        if (alpha >= 1.0) ctx.paint();
        else              ctx.paint_with_alpha(alpha);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// 
    /////////////////////////////////////////////////////////////////////
    
    public Cairo.Context context() {
        return new Cairo.Context(this.surface);;
    }
    
    public int width() {
        return this.surface.get_width();
    }
    
    public int height() {
        return this.surface.get_height();
    }
    
    public Clutter.CairoTexture create_actor() {
        var result = new Clutter.CairoTexture(this.width(), this.height());
        
        var ctx = result.create();
        ctx.set_source_surface(this.surface, 0, 0);
        ctx.paint();
        
        return result;
    }
}

}
