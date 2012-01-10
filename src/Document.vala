using Gtk;

public class Wrote.Document: Object {

  public File? file { get; construct set; default = null; }
  public Wrote.TextBuffer buffer { get; private set; }
  
  public string title { get; private set; default = "Untitled"; }

  private Cancellable cancellable;
  private Cancellable monitoring_cancellable;
  private FileMonitor monitor;
  
  construct {
    this.buffer = new Wrote.TextBuffer();
    this.cancellable = new Cancellable();
    this.monitoring_cancellable = new Cancellable();
    
    if (this.file != null)
      this.move(this.file);
  }

  public Document(File? f = null) {
    Object(file: f);
  }
  
  ~Document() {
    this.cancel();
    this.cancel_monitoring();
  }

  public void move(File to, bool save_as = false) {
    this.cancel_monitoring();
  
    this.file = to;  
    this.hookup_file();
  }
  
  public async bool save_as(File file) {
    this.cancel_monitoring();
    
    this.file = file;
    
    bool good = yield this.save();
    
    if (good) {
      this.hookup_file();
    }
    
    return good;
  }

  public void cancel() {
    this.cancellable.cancel();
    this.cancellable.reset();
  }

  public async bool load() {
    this.cancel();
    
    if (this.file == null)
      return false;
    
    uint8[] contents = null;
    string? etag = null;
    
    bool good = false;
    try {
      good = yield this.file.load_contents_async(this.cancellable, out contents, out etag);
    } catch (Error e) {
      error(e.message);
    }
    
    if (contents != null && good) {
      this.buffer.reset();
      this.buffer.set_modified(false);
      this.buffer.set_text((string) contents);
      
      return true;
    }
    
    return false;
  }
  
  public async bool save() {
    this.cancel();
    
    if (this.file == null)
      return false;
    
    bool good = false;
    
    try {
      good = yield this.file.replace_contents_async(
        this.buffer.text, 
        (size_t) this.buffer.text.length,
        null, 
        true,
        FileCreateFlags.PRIVATE,
        this.cancellable,
        null);
        
    } catch (Error e) {
      error(e.message);
    }
    
    this.buffer.set_modified(false);
    
    return good;
  }
  
  void cancel_monitoring() {
    this.monitoring_cancellable.cancel();
    this.monitoring_cancellable.reset();
  }
  
  void file_changed(File file, File? other, FileMonitorEvent event) {
    
  }
  
  void hookup_file() {
    try {
      this.monitor = this.file.monitor(FileMonitorFlags.NONE, this.monitoring_cancellable);
      this.monitor.changed.connect(this.file_changed);
    } catch (Error e) {
      error(e.message);
    }
    
    this.file.query_info_async(FILE_ATTRIBUTE_STANDARD_DISPLAY_NAME, 
      FileQueryInfoFlags.NONE,
      Priority.HIGH,
      null, 
      (o, r) => {
        
      try {
        FileInfo fileinfo = this.file.query_info_async.end(r);
        this.title = (string) fileinfo.get_display_name();
      } catch (Error e) {
        this.title = "Untitled";
        error(e.message);
      }
      
    });
  }
}

