using Gtk;

public class Wrote.Actions.Open: Gtk.Action, Wrote.Action {
  public string? accelerator { get; protected set; default = null; }
  
  construct {
    this.stock_id = "gtk-open";
    this.accelerator = "<Control>O";
  }
  
  public Open() {
    Object(name: "Open");
  }
  
  public override void activate() {
    Wrote.OpenFileChooser open_chooser = new Wrote.OpenFileChooser();
    
    open_chooser.run();
  }
}