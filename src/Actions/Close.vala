using Gtk;

public class Wrote.Actions.Close: Gtk.Action, Wrote.Action {
  
  public string? accelerator { get; protected set; default = null; }
  
  construct {
    this.stock_id = "gtk-close";
    this.accelerator = "<Control>W";
  }
  
  public Close() {
    Object(name: "Close");
  }

}