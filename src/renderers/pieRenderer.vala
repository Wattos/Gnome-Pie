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
/// This class renders a Pie. In order to accomplish that, it owns a
/// CenterRenderer and some SliceRenderers.
/////////////////////////////////////////////////////////////////////////

public class PieRenderer : GtkClutter.Embed {

    public SliceRenderer active_action { get; private set; default=null; }
    public SliceRenderer quick_action { get; private set; default=null; }
    
    public int slice_count { get; private set; default=0; }

    public Clutter.Stage stage { get; private set; default=null; }
    
    private CenterRenderer center = null;
    private Gee.ArrayList<SliceRenderer?> slices = null;
    
    public int size { get; private set; default = 100; }
    
    public PieRenderer() {
        this.stage = this.get_stage() as Clutter.Stage;
        this.stage.realize();
        
        this.stage.use_alpha = true;
        this.stage.color = Clutter.Color.from_string("#0000");
        
        this.slices = new Gee.ArrayList<SliceRenderer?>();
    }
    
    public void load_pie(Pie pie) {
        // unload previously loaded Pie
        this.stage.remove_all();
        this.slices.clear();
        this.active_action = null;      
        this.quick_action = null;
        this.slice_count = pie.action_count();
        
        int position = 0;
        
        // default size for Pies
        this.size = 2*(int)fmax(Config.global.theme.radius + 
                                Config.global.theme.slice_radius*Config.global.theme.max_zoom,
                                Config.global.theme.center_radius);
        
        // increase size if there are too many slices
        if (this.slice_count > 0) {
            this.size = (int)fmax(this.size,
                (((Config.global.theme.slice_radius + Config.global.theme.slice_gap)/tan(PI/this.slice_count)) 
                 + Config.global.theme.slice_radius)*2*Config.global.theme.max_zoom);
        }
        
        this.stage.set_size(size, size);
        
        // load all slices
        foreach (var group in pie.action_groups) {
            foreach (var action in group.actions) {
                var new_slice = new SliceRenderer(action, this, position++);
            
                if (action.is_quick_action) {
                    this.quick_action = new_slice;
                    this.active_action = new_slice;
                }

                this.slices.add(new_slice);
            }
        }
        
        // load the center
        this.center = new CenterRenderer(this.stage);
    }
    
    public void fade_in() {
        this.show();
        this.center.fade_in();
        
        foreach (var slice in slices)
            slice.fade_in();
    }
    
    public void mouse_moved(double x, double y) {
        this.center.mouse_moved(x-this.stage.width*0.5, y-this.stage.height*0.5);
        
        bool no_active_slice = true;
        
        foreach (var slice in slices) {
            if (slice.mouse_moved(x-this.stage.width*0.5, y-this.stage.height*0.5)) {
                this.active_action = slice;
                no_active_slice = false;
            }
        }
        
        if (no_active_slice)
            this.active_action = this.quick_action;
    }
    
    public void activate_slice() {
        if (this.active_action != null)
            this.active_action.action.activate();
        else if (this.quick_action != null)
            this.quick_action.action.activate();
        this.cancel();
    }
    
    public void cancel() {
        this.center.fade_out();
        
        foreach (var slice in slices)
            slice.fade_out();
        
        Timeout.add((uint)(Config.global.theme.fade_out_time*1000), () => {
            this.stage.remove_all();
            this.hide();
            return false;
        });
    }
}

}
