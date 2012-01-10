using Gtk;

public class Wrote.Actions.New: Gtk.Action, Wrote.Action {  
  public string? accelerator { get; protected set; default = null; }

  construct {
    this.stock_id = "gtk-new";
    this.accelerator = "<Control>N";
  }
  
  public New() {
    Object(name: "New");
  }
  
  public override void activate() {
    Wrote.APP.open_document(null);
  }
}