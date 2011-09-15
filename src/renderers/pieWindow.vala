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
/// An invisible window. Used to draw Pies onto.
/////////////////////////////////////////////////////////////////////////

public class PieWindow : Gtk.Window {

    /////////////////////////////////////////////////////////////////////
    /// The Renderer which renders the Pie.
    /////////////////////////////////////////////////////////////////////

    private PieRenderer renderer;
    
    
    /////////////////////////////////////////////////////////////////////
    /// Set to true, when the Pie is activatable.
    /////////////////////////////////////////////////////////////////////
    
    private bool active = false;


    /////////////////////////////////////////////////////////////////////
    /// C'tor, creates a new Window.
    /////////////////////////////////////////////////////////////////////

    public PieWindow() {
        this.renderer = new PieRenderer();
        this.add(renderer);
    
        // initialize attributes
        this.set_title("Gnome-Pie");
        this.set_skip_taskbar_hint(true);
        this.set_skip_pager_hint(true);
        this.set_keep_above(true);
        this.set_type_hint(Gdk.WindowTypeHint.SPLASHSCREEN);
        this.set_colormap(this.screen.get_rgba_colormap());
        this.set_decorated(false);
        this.set_resizable(false);
        this.icon_name = "gnome-pie";
        this.set_accept_focus(false);
        this.add_events(Gdk.EventMask.BUTTON_RELEASE_MASK |
                        Gdk.EventMask.KEY_RELEASE_MASK |
                        Gdk.EventMask.KEY_PRESS_MASK);

        // connect the left mouse button
        this.button_release_event.connect ((e) => {
            if (e.button == 1) this.activate_slice();
            else               this.cancel();
            return true;
        });
        
        // connect to key release when the according option is set
        this.key_release_event.connect ((e) => {
            if (!Config.global.click_to_activate)
                this.activate_slice();
            return true;
        });
        
        // connect cancel to Escape and activate to Return and Space
        this.key_press_event.connect ((e) => {
            if      (Gdk.keyval_name(e.keyval) == "Escape") this.cancel();
            else if (Gdk.keyval_name(e.keyval) == "Return") this.activate_slice();
            else if (Gdk.keyval_name(e.keyval) == "Space") this.activate_slice();
            return true;
        });
        
        // hide this window when the PieRenderer is hidden
        this.renderer.hide.connect(() => {
            GLib.Timeout.add((uint)(Config.global.theme.fade_out_time*1000), () => {
                this.hide();
                return false;
            });
        });
        
        // clear the window when there is nothing to be drawn
        this.expose_event.connect(() => {
            var ctx = Gdk.cairo_create(this.window);
            ctx.set_operator (Cairo.Operator.CLEAR);
            ctx.paint();

            return true;
        });
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Loads the given Pie. When openend, this Pie will be displayed.
    /////////////////////////////////////////////////////////////////////

    public void load_pie(Pie pie) {
        this.renderer.load_pie(pie);
        this.set_size_request(this.renderer.get_size(), this.renderer.get_size());
    }

    /////////////////////////////////////////////////////////////////////
    /// Opens the window. The previously loaded Pie is displayed.
    /////////////////////////////////////////////////////////////////////

    public void open() {
        this.active = true;
        
        if(Config.global.open_at_mouse) this.set_position(Gtk.WindowPosition.MOUSE);
        else                            this.set_position(Gtk.WindowPosition.CENTER);
        
        this.show();
        this.fix_focus();

        this.renderer.fade_in();
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Activates the currently selected Slice. And hides the window.
    /////////////////////////////////////////////////////////////////////

    private void activate_slice() {
        if (this.active) {
            this.active = false;
            this.unfix_focus();
            this.renderer.activate_slice();
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Cancles the Pie and hides the window.
    /////////////////////////////////////////////////////////////////////
    
    private void cancel() {
        if (this.active) {
            this.active = false;
            this.unfix_focus();
            this.renderer.cancel();
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Utilities for grabbing focus.
    /// Code from Gnome-Do/Synapse.
    /////////////////////////////////////////////////////////////////////
    
    private void fix_focus() {
        uint32 timestamp = Gtk.get_current_event_time();
        this.present_with_time(timestamp);
        this.get_window().raise();
        this.get_window().focus(timestamp);

        int i = 0;
        GLib.Timeout.add (100, () => {
            if (++i >= 100) return false;
            return !try_grab_window();
        });
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Code from Gnome-Do/Synapse.
    /////////////////////////////////////////////////////////////////////
    
    private void unfix_focus() {
        uint32 time = Gtk.get_current_event_time();
        Gdk.pointer_ungrab(time);
        Gdk.keyboard_ungrab(time);
        Gtk.grab_remove(this);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Code from Gnome-Do/Synapse.
    /////////////////////////////////////////////////////////////////////
    
    private bool try_grab_window() {
        uint time = Gtk.get_current_event_time();
        if (Gdk.pointer_grab (this.get_window(), true,
            Gdk.EventMask.BUTTON_PRESS_MASK | 
            Gdk.EventMask.BUTTON_RELEASE_MASK | 
            Gdk.EventMask.POINTER_MOTION_MASK, null, null, time) == Gdk.GrabStatus.SUCCESS) {
            
            if (Gdk.keyboard_grab(this.get_window(), true, time) == Gdk.GrabStatus.SUCCESS) {
                Gtk.grab_add(this);
                return true;
            } else {
                Gdk.pointer_ungrab(time);
                return false;
            }
        }
        return false;
    }  
}

}
