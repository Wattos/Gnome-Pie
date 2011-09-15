/////////////////////////////////////////////////////////////////////////    
/// This is no complete vapi --- I just *need* this one method!
/////////////////////////////////////////////////////////////////////////

[CCode (cprefix = "Clutter", lower_case_cprefix = "clutter_", cheader_filename = "clutter/x11/clutter-x11.h")]
namespace Clutter {
    namespace X11 {
        [CCode (cname = "clutter_x11_set_use_argb_visual")]
        public void set_use_argb_visual(bool use_argb);
    }
}
