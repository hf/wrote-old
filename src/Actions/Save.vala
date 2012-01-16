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
    Wrote.Window window = Wrote.APP.window as Wrote.Window;
    
    if (window.document.file == null) {
      window.actions.get_action("SaveAs").activate();
    } else {
      window.document.save.begin();
    }
  }
}