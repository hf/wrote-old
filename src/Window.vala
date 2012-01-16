using Gtk;
using Cairo;

public enum Wrote.MouseActivityState {
  ACTIVE,
  INACTIVE
}

public class Wrote.Window: Gtk.Window {
  
  public Wrote.Document document { get; construct set; }
  
  public Wrote.TextView text_view { get; private set; }
  public Wrote.Scroller scroller { get; private set; }
  public Wrote.Stats stats { get; private set; }
  
  public Gtk.ActionGroup actions { get; private set; }
  public Gtk.AccelGroup accelerators { get; private set; }
  
  public bool is_fullscreen { get; private set; default = false; }
  
  public Wrote.MouseActivityState mouse_activity_state { get; private set; default = Wrote.MouseActivityState.ACTIVE; }
  
  private Gtk.Box container;
  
  private uint inactivity_timeout = 0;
  
  construct {
    this.default_width = Wrote.Theme.WIDTH;
    this.default_height = Wrote.Theme.HEIGHT;
    
    this.app_paintable = true;    
    this.application = Wrote.APP;
    
    this.add_events(Gdk.EventMask.POINTER_MOTION_MASK);
    
    this.modify_title();
    this.document.notify["title"].connect(() => {
      this.modify_title();
    });
    
    this.document.buffer.modified_changed.connect(() => {
      this.modify_title();
    });
    
    this.container = new Gtk.Box(Gtk.Orientation.VERTICAL, 3);
    
    this.text_view = new Wrote.TextView(this.document);
    this.scroller = 
      new Wrote.Scroller(this.text_view.vadjustment, this.text_view.hadjustment);
    this.scroller.add(this.text_view);
    
    this.container.pack_start(this.scroller, true, true, 0);
    
    this.stats = new Wrote.Stats(this.document);
    this.container.pack_start(this.stats, false, false, 0);
    
    
    this.stats.halign = Gtk.Align.CENTER;
    this.stats.margin_top = Wrote.Theme.STATS_TOP_MARGIN;
    this.stats.margin_bottom = Wrote.Theme.STATS_BOTTOM_MARGIN;
    
    this.add(this.container);
    
    this.scroller.halign = Gtk.Align.CENTER;
    this.scroller.margin_top = Wrote.Theme.TOP_MARGIN;
    this.scroller.margin_bottom = Wrote.Theme.BOTTOM_MARGIN;
    this.scroller.margin_left = Wrote.Theme.LEFT_MARGIN;
    this.scroller.margin_right = Wrote.Theme.RIGHT_MARGIN;
    
    // TODO: Add menubar and hide it if not on a system with AppMenu
    
    Wrote.Actions.New action_new = new Wrote.Actions.New();
    Wrote.Actions.Open action_open = new Wrote.Actions.Open();
    Wrote.Actions.Save action_save = new Wrote.Actions.Save();
    Wrote.Actions.SaveAs action_save_as = new Wrote.Actions.SaveAs();
    Wrote.Actions.Fullscreen action_fullscreen = new Wrote.Actions.Fullscreen();
    Wrote.Actions.About action_about = new Wrote.Actions.About();
    Wrote.Actions.Close action_close = new Wrote.Actions.Close();
    
    this.actions = new Gtk.ActionGroup("Actions");
    this.accelerators = new Gtk.AccelGroup();
    
    action_new.add_to(this.actions);
    action_open.add_to(this.actions);
    action_save.add_to(this.actions);
    action_save_as.add_to(this.actions);
    action_fullscreen.add_to(this.actions);
    action_about.add_to(this.actions);
    action_close.add_to(this.actions);
    
    action_new.add_to_accel_group(this.accelerators);
    action_open.add_to_accel_group(this.accelerators);
    action_save.add_to_accel_group(this.accelerators);
    action_save_as.add_to_accel_group(this.accelerators);
    action_fullscreen.add_to_accel_group(this.accelerators);
    action_about.add_to_accel_group(this.accelerators);
    action_close.add_to_accel_group(this.accelerators);
    
    this.notify["mouse-activity-state"].connect(() => {
      if (this.mouse_activity_state == Wrote.MouseActivityState.ACTIVE)
        this.stats.fade_in();
      else
        this.stats.fade_out();
    });
    
    this.add_accel_group(this.accelerators);
  }
  
  public Window(Wrote.Document? d = null) {
    Wrote.Document? document = d;
    if (d == null) {
      document = new Wrote.Document();
    }
    
    Object(document: document);
  }
  
  public override void show() {
    base.show();
    
    this.mouse_activity();
  }
  
  public override bool delete_event(Gdk.EventAny event) {
    
    this.hide();
    this.destroy();
    
    return true;    
  }
  
  public override bool draw(Cairo.Context ctx) {
    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
    
    ctx.paint();
    
    this.propagate_draw(this.get_child(), ctx);
    
    return true;
  }
  
  public override bool window_state_event(Gdk.EventWindowState event) {
    if ((event.new_window_state & Gdk.WindowState.FULLSCREEN) != 0) {
      this.is_fullscreen = true;
    } else {
      this.is_fullscreen = false;
    }
    
    return false;
  }
  
  public void mouse_activity() {
    if (this.inactivity_timeout != 0) {
      Source.remove(this.inactivity_timeout);
      this.inactivity_timeout = 0;
    }
    
    this.inactivity_timeout = 
      Timeout.add_seconds(Wrote.Theme.INACTIVITY_TIMEOUT, this.inactive_timeout);
    
    if (this.mouse_activity_state != Wrote.MouseActivityState.ACTIVE)
      this.mouse_activity_state = Wrote.MouseActivityState.ACTIVE;
  }
  
  public override bool motion_notify_event(Gdk.EventMotion event) {
    this.mouse_activity();
    
    return false;
  }
  
  void modify_title() {
    this.title = 
      (this.document.buffer.get_modified() ? "*" : "") + this.document.title;
  }
  
  bool inactive_timeout() {
    this.inactivity_timeout = 0;
    
    if (this.mouse_activity_state != Wrote.MouseActivityState.INACTIVE)
      this.mouse_activity_state = Wrote.MouseActivityState.INACTIVE;
    
    return false;
  }
}
