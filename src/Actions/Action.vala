using Gtk;

public interface Wrote.Action: Gtk.Action {
  public abstract string? accelerator { get; protected set; default = null; }
  
  public void add_to(Gtk.ActionGroup group, bool with_accel = true) {
    if (with_accel) {
      group.add_action_with_accel(this, this.accelerator);
      return;
    }
    
    group.add_action(this);
  }
  
  public void add_to_accel_group(Gtk.AccelGroup accel_group) {
    this.set_accel_group(accel_group);
    this.connect_accelerator();
  }
}