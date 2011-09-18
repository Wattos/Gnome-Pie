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
    
    public Action action { get; private set; default=null; }
    
    private Clutter.CairoTexture active_slice = null;
    private Clutter.CairoTexture inactive_slice = null;
    
    private Clutter.State states = null;
    private double direction;
    private unowned PieRenderer parent = null;
    private Clutter.Animator anim = null;
    
    public SliceRenderer(Action action, PieRenderer parent, int position) {
        this.action = action;
        this.parent = parent;
        this.direction = 2.0 * PI * (double)position/(double)parent.slice_count;

        double radius = Config.global.theme.radius;
        
        // increase radius for Pies full of slices
        if (atan((Config.global.theme.slice_radius+Config.global.theme.slice_gap)
                 /(radius/Config.global.theme.max_zoom)) > PI/parent.slice_count) {
                 
            radius = (Config.global.theme.slice_radius+Config.global.theme.slice_gap)
                     /tan(PI/parent.slice_count)*Config.global.theme.max_zoom;
        }
        
        var active_icon = new ThemedIcon(action.icon, true);
            this.active_slice = active_icon.create_actor();
            this.active_slice.set_scale(1.0/Config.global.theme.max_zoom, 1.0/Config.global.theme.max_zoom);
            this.active_slice.set_opacity(0);
            this.active_slice.set_position(parent.stage.width*0.5f, parent.stage.height*0.5f);
            this.active_slice.set_anchor_point((float)(-cos(direction)*radius) + this.active_slice.width*0.5f, 
                                               (float)(-sin(direction)*radius) + this.active_slice.height*0.5f);
            
            try {
                this.active_slice.cogl_material.set_blend("RGBA = ADD (SRC_COLOR, DST_COLOR)");
            } catch (Cogl.BlendStringError e) {
                warning(e.message);
            }
            
            parent.stage.add_actor(this.active_slice);
        
        
        var inactive_icon = new ThemedIcon(action.icon, false);
            this.inactive_slice = inactive_icon.create_actor();
            this.inactive_slice.set_scale(1.0/Config.global.theme.max_zoom, 1.0/Config.global.theme.max_zoom);
            this.inactive_slice.set_opacity(255);
            this.inactive_slice.set_position(parent.stage.width*0.5f, parent.stage.height*0.5f);
            this.inactive_slice.set_anchor_point((float)(-cos(direction)*radius) + this.inactive_slice.width*0.5f, 
                                                 (float)(-sin(direction)*radius) + this.inactive_slice.height*0.5f);
            
            try {
                this.inactive_slice.cogl_material.set_blend("RGBA = ADD (SRC_COLOR, DST_COLOR)");
            } catch (Cogl.BlendStringError e) {
                warning(e.message);
            }
            
            parent.stage.add_actor(this.inactive_slice);
            
        this.states = new Clutter.State();
        this.states.set_key("inactive", "active", this.active_slice, "opacity", Clutter.AnimationMode.LINEAR, (uint)255, 0.0, 0.0);
        this.states.set_key("inactive", "active", this.inactive_slice, "opacity", Clutter.AnimationMode.LINEAR, (uint)0, 0.0, 0.0);
        this.states.set_key("active", "inactive", this.active_slice, "opacity", Clutter.AnimationMode.LINEAR, (uint)0, 0.0, 0.0);
        this.states.set_key("active", "inactive", this.inactive_slice, "opacity", Clutter.AnimationMode.LINEAR, (uint)255, 0.0, 0.0);
                            
        this.states.set_duration(null, null, (uint)(Config.global.theme.transition_time*1000.0));
    }

    
    public void fade_in() {
        this.anim = new Clutter.Animator();
        this.anim.duration = (uint)(Config.global.theme.fade_in_time*1000);
        
        this.anim.set_key(this.inactive_slice, "opacity", Clutter.AnimationMode.LINEAR, 0.0, (uint)0);
        this.anim.set_key(this.inactive_slice, "scale_x", Clutter.AnimationMode.LINEAR, 0.0, 0.5/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "scale_y", Clutter.AnimationMode.LINEAR, 0.0, 0.5/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "rotation_angle_z", Clutter.AnimationMode.LINEAR, 0.0, -30.0);
        
        this.anim.set_key(this.inactive_slice, "opacity", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, (uint)255);
        this.anim.set_key(this.inactive_slice, "scale_x", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 1.0/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "scale_y", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 1.0/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "rotation_angle_z", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 0.0);
        
        this.anim.start();
    }
    
    public void fade_out() {
        this.anim = new Clutter.Animator();
        this.anim.duration = (uint)(Config.global.theme.fade_out_time*1000);
    
        this.anim.set_key(this.active_slice, "opacity", Clutter.AnimationMode.LINEAR, 0.5, this.active_slice.opacity);

        this.anim.set_key(this.inactive_slice, "opacity", Clutter.AnimationMode.LINEAR, 0.0, this.inactive_slice.opacity);
        this.anim.set_key(this.inactive_slice, "scale_x", Clutter.AnimationMode.LINEAR, 0.0, this.inactive_slice.scale_x);
        this.anim.set_key(this.inactive_slice, "scale_y", Clutter.AnimationMode.LINEAR, 0.0, this.inactive_slice.scale_y);
        this.anim.set_key(this.inactive_slice, "rotation_angle_z", Clutter.AnimationMode.EASE_OUT_CUBIC, 0.0, 0.0);

        this.anim.set_key(this.active_slice, "opacity", Clutter.AnimationMode.LINEAR, 1.0, (uint)0);

        this.anim.set_key(this.inactive_slice, "opacity", Clutter.AnimationMode.LINEAR, 1.0, (uint)0);
        this.anim.set_key(this.inactive_slice, "scale_x", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 0.8/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "scale_y", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 0.8/Config.global.theme.max_zoom);
        this.anim.set_key(this.inactive_slice, "rotation_angle_z", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, 30.0);

        this.anim.start();
    }
    
    public bool mouse_moved(double x, double y) {
        double distance = this.calc_distance(x, y);
    
        if (parent.quick_action != null && parent.active_action == parent.quick_action && distance < Config.global.theme.active_radius) {
            x = parent.quick_action.x();
            y = parent.quick_action.y();
            distance = this.calc_distance(x, y);
        }
    
        double diff = this.calc_mouse_diff(x, y, distance);
        
        bool active = this.calc_active(diff, distance);
        
        if (active) {
            this.states.set_state("active");
        } else {
            this.states.set_state("inactive");
        }
        
        double max_scale = this.calc_scale(diff);
        
        this.active_slice.animate(Clutter.AnimationMode.LINEAR, (uint)(Config.global.theme.transition_time*300.0), "scale_x", max_scale);
        this.active_slice.animate(Clutter.AnimationMode.LINEAR, (uint)(Config.global.theme.transition_time*300.0), "scale_y", max_scale);
        
        this.inactive_slice.animate(Clutter.AnimationMode.LINEAR, (uint)(Config.global.theme.transition_time*300.0), "scale_x", max_scale);
        this.inactive_slice.animate(Clutter.AnimationMode.LINEAR, (uint)(Config.global.theme.transition_time*300.0), "scale_y", max_scale);
        
        return active;
    }
    
    public double x() {
        return this.active_slice.width*0.5-(double)this.active_slice.anchor_x;
    }
    
    public double y() {
        return this.active_slice.height*0.5-(double)this.active_slice.anchor_y;
    }
    
    private double calc_distance(double x, double y) {
        return sqrt(x*x + y*y);
    }
    
    private double calc_mouse_diff(double x, double y, double distance) {
	    double angle = 0.0;
	    
	    if (distance > 0) {
	        angle = acos(x/distance);
		    if (y < 0) 
		        angle = 2*PI - angle;
	    }
	    
	    double diff = fabs(angle-this.direction);
        
        if (diff > PI)
	        diff = 2 * PI - diff;
	    
	    return diff;
    }
    
    private bool calc_active(double mouse_diff, double distance) {
        bool out_side = distance > Config.global.theme.active_radius;
        return (out_side && mouse_diff < PI/this.parent.slice_count)
            || (!out_side && parent.quick_action == this);
    }
    
    private double calc_scale(double mouse_diff) {
        double max_scale = 1.0/Config.global.theme.max_zoom;

        if (mouse_diff < 2 * PI * Config.global.theme.zoom_range && parent.active_action != null) {
            
            max_scale = (Config.global.theme.max_zoom/(mouse_diff * (Config.global.theme.max_zoom - 1)
                        /(2 * PI * Config.global.theme.zoom_range) + 1))
                        /Config.global.theme.max_zoom;
        }
        
        return max_scale;
    }
}

}
