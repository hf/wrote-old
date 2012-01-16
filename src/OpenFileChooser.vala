using Gtk;

public class Wrote.OpenFileChooser: Gtk.FileChooserDialog {
  construct {
    this.action = Gtk.FileChooserAction.OPEN;
    
    this.add_button("gtk-ok", Gtk.ResponseType.OK);
    this.add_button("gtk-cancel", Gtk.ResponseType.CANCEL);
    
    this.set_default_response(Gtk.ResponseType.OK);
    
    this.transient_for = Wrote.APP.window;
    
    this.title = "Open File";
    
    this.set_filter(Wrote.APP.file_filter);
  }
  
  public override void response(int response) {
    Wrote.Window window = this.transient_for as Wrote.Window;
    
    if (response == Gtk.ResponseType.OK) {
      window.document.move(this.get_file());
      
      window.document.load.begin((o, r) => {
        // FIXME: Report error if the loading wasn't successful!
        if (window.document.load.end(r)) {
          this.hide();
          this.destroy();
        }
      });
      
    } else {
      this.hide();
      this.destroy();
    }
  }
  
  public override bool delete_event(Gdk.EventAny event) {    
    this.response(Gtk.ResponseType.CANCEL);
    
    return true;
  }
}