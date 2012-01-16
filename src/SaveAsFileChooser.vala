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
    
    Wrote.Window window = Wrote.APP.window as Wrote.Window;
    
    this.transient_for = window;
    
    this.title = "Save File As";
    
    this.set_filter(Wrote.APP.file_filter);
    
    
    if (window.document.file != null) {
      this.set_file(window.document.file);
    } else {
      string documents = 
        Environment.get_user_special_dir(UserDirectory.DOCUMENTS);
      
      this.set_current_folder(documents);
      this.set_current_name("Untitled.txt");
    }
  }
  
  public override void response(int response) {
    
    if (response == Gtk.ResponseType.OK) {
      
      File selected_file = this.get_file();
      Wrote.Window window = Wrote.APP.window as Wrote.Window;
      
      window.document.save_as(selected_file, null, (o, r) => {
        bool result = window.document.save_as.end(r);
        
        if (result) {
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