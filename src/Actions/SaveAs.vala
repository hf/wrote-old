using Gtk;

public class Wrote.Actions.SaveAs: Gtk.Action, Wrote.Action {
  public string? accelerator { get; protected set; default = null; }

  construct {
    this.stock_id = "gtk-save-as";
    this.accelerator = "<Control><Shift>S";
  }
  
  public SaveAs() {
    Object(name: "SaveAs");
  }
  
  public override void activate() {
    Wrote.SaveAsFileChooser save_as_chooser = new Wrote.SaveAsFileChooser();
    save_as_chooser.run();
  }
}