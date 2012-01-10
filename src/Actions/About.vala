using Gtk;

public class Wrote.Actions.About: Gtk.Action, Wrote.Action {
  public string? accelerator { get; private set; }
  
  construct {
    this.stock_id = "gtk-about";
    this.accelerator = "<Control>A";
  }
  
  public About() {
    Object(name: "About");
  }
  
  public override void activate() {
    Wrote.AboutDialog about_dialog = new Wrote.AboutDialog();
    about_dialog.run();
  }
}