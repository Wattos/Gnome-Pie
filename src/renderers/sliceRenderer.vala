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

using GLib.Math;

namespace GnomePie {

/////////////////////////////////////////////////////////////////////////    
/// Renders a Slice of a Pie. According to the current theme.
/////////////////////////////////////////////////////////////////////////

public class SliceRenderer : GLib.Object {
    
    private Clutter.Actor active_slice = null;
    private Clutter.Actor inactive_slice = null;
    
    public SliceRenderer(Action action, Clutter.Stage stage, int position, int total_slices) {
        double direction = 2.0 * PI * (double)position/(double)total_slices;
        double radius = Config.global.theme.radius;
        
        // increase radius for Pies full of slices
        if (atan((Config.global.theme.slice_radius+Config.global.theme.slice_gap)
                 /(radius/Config.global.theme.max_zoom)) > PI/total_slices) {
                 
            radius = (Config.global.theme.slice_radius+Config.global.theme.slice_gap)
                     /tan(PI/total_slices)*Config.global.theme.max_zoom;
        }
        
        var active_icon = new ThemedIcon(action.icon, true);
            this.active_slice = active_icon.create_actor();
            this.active_slice.set_opacity(255);
            this.active_slice.set_position(stage.width*0.5f, stage.height*0.5f);
            this.active_slice.set_anchor_point((float)(cos(direction)*radius) + this.active_slice.width*0.5f, 
                                               (float)(sin(direction)*radius) + this.active_slice.height*0.5f);
            
            stage.add_actor(this.active_slice);
        
        
        var inactive_icon = new ThemedIcon(action.icon, false);
            this.inactive_slice = inactive_icon.create_actor();
            this.inactive_slice.set_opacity(255);
            this.inactive_slice.set_position(stage.width*0.5f, stage.height*0.5f);
            this.inactive_slice.set_anchor_point((float)(cos(direction)*radius) + this.inactive_slice.width*0.5f, 
                                                 (float)(sin(direction)*radius) + this.inactive_slice.height*0.5f);
            
            stage.add_actor(this.inactive_slice);
    }
    
    public void fade_in() {
        
    }
    
    public void fade_out() {
    
    }
    
    public void mouse_moved(double x, double y) {
        
    }
}

}
