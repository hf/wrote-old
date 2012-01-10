using Gtk;

public class Wrote.AboutDialog: Gtk.AboutDialog {
  
  construct {
    this.program_name = "Wrote";
    this.authors = {"Stojan Dimitrovski"};
    this.copyright = "Strojan Dimitrovski © 2011";
    
    this.transient_for = Wrote.APP.window;
  }
  
  public override void response(int response) {
    this.hide();
    this.destroy();
  }
}