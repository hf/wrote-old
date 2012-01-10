using Gtk;

public class Wrote.Actions.Save: Gtk.Action, Wrote.Action {
  public string? accelerator { get; protected set; default = null; }
  
  construct {
    this.stock_id = "gtk-save";
    this.accelerator = "<Control>S";
  }
  
  public Save() {
    Object(name: "Save");
  }
  
  public override void activate() {
    if ((Wrote.APP.window as Wrote.Window).document.file == null) {
      (Wrote.APP.window as Wrote.Window).actions.get_action("SaveAs").activate();
    } else {
      (Wrote.APP.window as Wrote.Window).document.save.begin();
    }
  }
}