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
/// This class renders a Pie. In order to accomplish that, it owns a
/// CenterRenderer and some SliceRenderers.
/////////////////////////////////////////////////////////////////////////

public class PieRenderer : GtkClutter.Embed {

    public Clutter.Stage stage = null;
    private CenterRenderer center_renderer = null;
    
    public PieRenderer() {
        this.stage = this.get_stage() as Clutter.Stage;
        this.stage.realize();
        
        this.stage.use_alpha = true;
        this.stage.color = Clutter.Color.from_string("#0000");
        
        this.center_renderer = new CenterRenderer();
    }
    
    public void load_pie(Pie pie) {
        this.stage.remove_all();
        this.center_renderer.load(this.stage);
    }
    
    public void fade_in() {
        this.show();
        this.center_renderer.fade_in();
    }
    
    public void activate_slice() {
        this.cancel();
    }
    
    public void cancel() {
        this.center_renderer.fade_out();
        
        Timeout.add((uint)(Config.global.theme.fade_out_time*1000), () => {
            this.hide();
            return false;
        });
    }
    
    public int get_size() {
        /// TODO
        return 400;
    }
}

}
