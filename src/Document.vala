using Gtk;

public enum Wrote.DocumentNewlineType {
  LF = DataStreamNewlineType.LF,
  CR = DataStreamNewlineType.CR,
  CRLF = DataStreamNewlineType.CR_LF,
  ANY  = DataStreamNewlineType.ANY
}

// FIXME: Support different line ending types.

public class Wrote.Document: Object {
  public const int BUFSIZE = 4096;
  
  public File? file { 
    get; 
    construct set; 
    default = null; 
  }
  
  public string encoding { 
    get; 
    construct set; 
    default = "UTF-8"; 
  }
  
  public Wrote.TextBuffer buffer { 
    get; 
    private set; 
  }
  
  public string title { 
    get; 
    private set; 
    default = "Untitled"; 
  }
  
  construct {
    this.buffer = new Wrote.TextBuffer();
  }
  
  public Document(File? f = null, string? enc = null) {
    string? e = enc;
    
    if (e == null) {
      e = "UTF-8";
    }
    
    Object(file: f, encoding: e);
  }
  
  public async bool load() {
    if (this.file == null)
      return false;
    
    FileInputStream? input = null;
    
    try {
      input = yield this.file.read_async(Priority.DEFAULT);
    } catch (Error e) {
      error(e.message);
    }
    
    CharsetConverter? converter = null;
    
    try {
      converter = new CharsetConverter("UTF-8", this.encoding);
    } catch (Error e) {
      error(e.message);
    }
    
    ConverterInputStream converter_input = 
      new ConverterInputStream(input, converter);
    
    DataInputStream data_input = new DataInputStream(converter_input);
  
    this.buffer.text = "";
    
    Gtk.TextIter end;
    
    size_t length = 0;
    uint8[] buf = new uint8[BUFSIZE];
    
    do {
      
      try {
        length = yield data_input.read_async(buf, Priority.DEFAULT);
      } catch (Error e) {
        length = -1;
        error(e.message);
      }
      
      if (length > 0) {
        this.buffer.get_end_iter(out end);
        this.buffer.insert_text(ref end, (string) buf, (int) length);
      }
      
    } while (length > 0);
    
    return true;
  }
  
  public void move(File to, string? encoding = null) {
    if (encoding != null) {
      this.encoding = encoding;
    }
    
    this.file = to;
  }
  
  public async bool save() {
    if (this.file == null)
      return false;
    
    FileOutputStream? output = null;
    
    try {
      output = yield this.file.replace_async(
        null, 
        true, 
        FileCreateFlags.PRIVATE,
        Priority.DEFAULT);
    } catch (Error e) {
      error(e.message);
    }
    
    CharsetConverter? converter = null;
    
    try {
      converter = new CharsetConverter(this.encoding, "UTF-8");
    } catch (Error e) {
      error(e.message);
    }
    
    ConverterOutputStream? converted_output = null;
    
    try {
      converted_output = new ConverterOutputStream(output, converter);
    } catch (Error e) {
      error(e.message);
    }
    
    DataOutputStream? data_output = null;
    
    try {
      data_output = new DataOutputStream(converted_output);
    } catch (Error e) {
      error(e.message);
    }
    
    Gtk.TextIter start, end;
    this.buffer.get_start_iter(out start);
    end = start;
    
    do {
      end = start;
      end.forward_chars(BUFSIZE);
      
      string text = this.buffer.get_text(start, end, false);
      
      try {
        yield data_output.write_async(text.data, Priority.HIGH);
      } catch (Error e) {
        error(e.message);
      }
      
      start = end;
      
    } while (!end.is_end());
    
    this.buffer.set_modified(false);
    
    return true;
  }
  
  public async bool save_as(File as, string? enc = null) {    
    this.move(as, enc);
    
    return yield this.save();
  }
}