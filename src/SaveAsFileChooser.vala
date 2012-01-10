using Gtk;

public class Wrote.SaveAsFileChooser: Gtk.FileChooserDialog {
  
  construct {
    this.action = Gtk.FileChooserAction.SAVE;
    
    if ((Wrote.APP.window as Wrote.Window).document.file != null) {
      this.set_file((Wrote.APP.window as Wrote.Window).document.file);
    }
    
    this.add_button("gtk-ok", Gtk.ResponseType.OK);
    this.add_button("gtk-cancel", Gtk.ResponseType.CANCEL);
    
    this.set_default_response(Gtk.ResponseType.OK);
    
    this.transient_for = Wrote.APP.window;
    
    this.set_filter(Wrote.APP.file_filter);
  }
  
  public override void response(int response) {
    
    if (response == Gtk.ResponseType.OK) {
      (this.transient_for as Wrote.Window).document.save_as.begin(this.get_file(), (o, r) => {
        // FIXME: Report error if the loading wasn't successful!
        if ((this.transient_for as Wrote.Window).document.save_as.end(r)) {
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