using Gtk;
using Config;

namespace Wrote {
  public static Wrote.App? APP = null;
}

public class Wrote.App: Gtk.Application {
  
  public Gtk.Window? window { 
    get {
      if (this.get_windows().first() == null)
        return null;
        
      return this.get_windows().first().data;
    }
  }
  
  public Gtk.FileFilter file_filter { get; private set; }
  
  construct {
    this.flags |= GLib.ApplicationFlags.HANDLES_OPEN;
    
    this.file_filter = new Gtk.FileFilter();
    this.file_filter.add_mime_type("text/plain");
    this.file_filter.add_mime_type("text/x-markdown");
    
    Wrote.Theme.init();
  }
  
  public App() {
    Object(application_id: "org.wrote.Wrote");
  }
  
  ~App() {
    Wrote.Theme.deinit();
  }
   
  public override void startup() {
    base.startup();
  }
  
  public override void activate() {
    base.activate();
    
    if (this.get_windows().length() < 1) {
      this.open_document();
    }
  }
  
  public override void open(File[] files, string hint) {
    base.open(files, hint);
    
    for (int i = 0; i < files.length; i++) {
      this.open_document(files[i]);
    }
  }
  
  public static int main(string[] args) {
    Wrote.APP = new Wrote.App();
    
    return Wrote.APP.run(args);
    
    /* MainLoop loop = new MainLoop();
    
    Wrote.Document document = new Wrote.Document(File.new_for_commandline_arg(args[1]));
    
    document.load.begin((o, r) => {
      stdout.printf("%s\n", document.buffer.text);
    });
    
    loop.run();
    
    return 0; */
  }
  
  public Wrote.Window open_document(File? file = null) {
    Wrote.Document document = new Wrote.Document(file);
    document.load.begin();
    
    Wrote.Window window = new Wrote.Window(document);
    
    window.show_all();
    
    return window;
  }
}
