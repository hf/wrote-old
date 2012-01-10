using Gtk;

public class Wrote.Actions.Fullscreen: Gtk.ToggleAction, Wrote.Action {
  public string? accelerator { get; protected set; default = null; }
  
  construct {
    this.stock_id = "gtk-fullscreen";
    this.accelerator = "<Control>F";
  }
  
  public Fullscreen() {
    Object(name: "Fullscreen");
  }
  
  public override void activate() {
    if ((Wrote.APP.window as Wrote.Window).is_fullscreen) {
      Wrote.APP.window.unfullscreen();
    } else {
      Wrote.APP.window.fullscreen();
    }
  }
}