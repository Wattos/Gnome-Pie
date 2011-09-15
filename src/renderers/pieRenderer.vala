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

    private Clutter.Stage stage = null;
    
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
        this.stage.remove_all();
        this.slices.clear();
        
        int count = pie.action_count();
        int position = 0;
        
        // default size for Pies
        this.size = 2*(int)fmax(Config.global.theme.radius + 
                                Config.global.theme.slice_radius*Config.global.theme.max_zoom,
                                Config.global.theme.center_radius);
        
        // increase size if there are many slices
        if (count > 0) {
            this.size = (int)fmax(this.size,
                (((Config.global.theme.slice_radius + Config.global.theme.slice_gap)/tan(PI/count)) 
                 + Config.global.theme.slice_radius)*2*Config.global.theme.max_zoom);
        }
        
        this.stage.set_size(size, size);
        
        // load all slices
        foreach (var group in pie.action_groups) {
            foreach (var action in group.actions) {
                this.slices.add(new SliceRenderer(action, this.stage, position++, count));
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
        this.center.mouse_moved(x-this.stage.width, y-this.stage.height);
        
        foreach (var slice in slices)
            slice.mouse_moved(x-this.stage.width, y-this.stage.height);
    }
    
    public void activate_slice() {
        this.cancel();
    }
    
    public void cancel() {
        this.center.fade_out();
        
        foreach (var slice in slices)
            slice.fade_out();
        
        Timeout.add((uint)(Config.global.theme.fade_out_time*1000), () => {
            this.hide();
            return false;
        });
    }
}

}
