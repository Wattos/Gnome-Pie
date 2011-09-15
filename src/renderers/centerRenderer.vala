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

// Renders the center of a Pie.

public class CenterRenderer : GLib.Object {

    private Gee.ArrayList<Clutter.Actor?> layers = null;
    private Clutter.Animator anim = null;
    private Clutter.Animator anim2 = null;

    public CenterRenderer(Clutter.Stage stage) {
        this.layers = new Gee.ArrayList<Clutter.Actor?>();
    
        foreach(var layer in Config.global.theme.center_layers) {
            var actor = layer.image.create_actor();

            actor.set_position(stage.width*0.5f, stage.height*0.5f);
            actor.set_anchor_point(actor.width*0.5f, actor.height*0.5f);
            actor.opacity = 0;
            actor.scale_y = 0.5f;
            actor.scale_x = 0.5f;
                
            stage.add_actor(actor);
            layers.add(actor);
        }
    }
    
    public void fade_in() {
    
        this.anim = new Clutter.Animator();
        this.anim.duration = (uint)(Config.global.theme.fade_in_time*5000);
        
        this.anim2 = new Clutter.Animator();
        var timeline = new Clutter.Timeline(3000);
        timeline.set_loop(true);
        this.anim2.set_timeline(timeline);
    
        for(int i = 0; i<layers.size; ++i) {
            this.anim.set_key(layers[i], "opacity", Clutter.AnimationMode.LINEAR, 0.0, (uint)0);
            this.anim.set_key(layers[i], "scale_x", Clutter.AnimationMode.LINEAR, 0.0, 0.1);
            this.anim.set_key(layers[i], "scale_y", Clutter.AnimationMode.LINEAR, 0.0, 0.1);
            
            this.anim.set_key(layers[i], "opacity", Clutter.AnimationMode.EASE_OUT_CUBIC, 1.0, (uint)255);
            this.anim.set_key(layers[i], "scale_x", Clutter.AnimationMode.EASE_OUT_ELASTIC, 1.0, 1.0);
            this.anim.set_key(layers[i], "scale_y", Clutter.AnimationMode.EASE_OUT_ELASTIC, 1.0, 1.0);
        }
        
        for(int i = 0; i<layers.size; ++i) {
            this.anim2.set_key(layers[i], "rotation_angle_z", Clutter.AnimationMode.LINEAR, 0.0, 0.0);
            this.anim2.set_key(layers[i], "rotation_angle_z", Clutter.AnimationMode.LINEAR, 1.0, 360.0);
        }
        
        this.anim.start();
        this.anim2.start();
    }
    
    public void fade_out() {
    
        this.anim = new Clutter.Animator();
        this.anim.duration = (uint)(Config.global.theme.fade_out_time*1000);
    
        for(int i = 0; i<layers.size; ++i) {
            this.anim.set_key(layers[i], "opacity", Clutter.AnimationMode.LINEAR, 0.0, layers[i].opacity);
            this.anim.set_key(layers[i], "scale_x", Clutter.AnimationMode.LINEAR, 0.0, layers[i].scale_x);
            this.anim.set_key(layers[i], "scale_y", Clutter.AnimationMode.LINEAR, 0.0, layers[i].scale_y);
            
            this.anim.set_key(layers[i], "opacity", Clutter.AnimationMode.EASE_IN_CUBIC, 1.0, (uint)0);
            this.anim.set_key(layers[i], "scale_x", Clutter.AnimationMode.EASE_IN_CUBIC, 1.0, (double)0.5);
            this.anim.set_key(layers[i], "scale_y", Clutter.AnimationMode.EASE_IN_CUBIC, 1.0, (double)0.5);
        }
        
        this.anim.start();
        
    }
    
    public void mouse_moved(double x, double y) {
        
    }
}

}
