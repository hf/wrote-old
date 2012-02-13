/*
 * Document.vala
 * This file is part of Wrote
 *
 * Copyright (C) 2012 - Stojan Dimitrovski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

using Gtk;

public enum Wrote.DocumentNewlineType {
  LF = DataStreamNewlineType.LF,
  CR = DataStreamNewlineType.CR,
  CRLF = DataStreamNewlineType.CR_LF,
  ANY  = DataStreamNewlineType.ANY
}

public enum Wrote.DocumentState {
  NORMAL,
  LOADING,
  SAVING
}

public errordomain Wrote.DocumentError {
  FILE_NOT_FOUND,
  FILE_IS_DIRECTORY,
  ENCODING_CONVERSION_FAILED,
  PERMISSION_DENIED
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
    set;
    default = "UTF-8";
  }

  public Wrote.TextBuffer buffer {
    get;
    private set;
  }

  public Wrote.DocumentState state {
    get;
    private set;
    default = Wrote.DocumentState.NORMAL;
  }

  public string title {
    get;
    private set;
    default = "Untitled";
  }

  public bool modified {
    get {
      return this.buffer.get_modified();
    }

    private set {
      this.buffer.set_modified(value);
    }
  }

  public bool has_file {
    get {
      return (this.file != null);
    }
  }

  public virtual signal void transition
  (Wrote.DocumentState o, Wrote.DocumentState n, bool success = true)
  {
    if (this.state != n)
      this.state = n;
  }

  private uint8[] readbuf;

  construct {
    this.buffer = new Wrote.TextBuffer();

    this.buffer.modified_changed.connect(() => {
      this.notify_property("modified");
    });

    this.notify["file"].connect(() => {
      if (file == null) {
        this.title = "Untitled";
      }
    });

    this.readbuf = new uint8[BUFSIZE];
  }

  public Document(File? f = null, string? enc = null) {
    string? e = enc;

    if (e == null) {
      e = "UTF-8";
    }

    Object(file: f, encoding: e);
  }

  // resets everything as if a new file, don't play with this!
  public void wipe() {
    this.file = null;
    this.encoding = "UTF-8";
    this.buffer.text = "";
    this.buffer.set_modified(true);
  }

  public async bool load() throws Wrote.DocumentError {
    if (this.file == null)
      return false;

    #if DEBUG
    stdout.printf("Loading file '%s' as %s.\n", this.file.get_uri(), this.encoding);
    #endif

    this.transition(this.state, Wrote.DocumentState.LOADING);

    FileInputStream? input = null;

    try {
      input = yield this.file.read_async(Priority.DEFAULT);
    } catch (Error e) {
      #if DEBUG
      warning(e.message);
      #endif

      this.transition(this.state, Wrote.DocumentState.NORMAL, false);

      if (e is IOError.NOT_FOUND) {
        throw new Wrote.DocumentError.FILE_NOT_FOUND(
          "The file “%s” does not exist.",
          this.file.get_basename());

      } else if (e is IOError.IS_DIRECTORY) {
        throw new Wrote.DocumentError.FILE_IS_DIRECTORY(
          "You tried to open “%s”, which is a directory.",
          this.file.get_basename());

      } else if (e is IOError.PERMISSION_DENIED) {
        throw new Wrote.DocumentError.PERMISSION_DENIED(
          "Permission was denied reading “%s”.",
          this.file.get_basename());

      } else {
        warning(e.message);
      }
    }

    yield this.query_title();

    CharsetConverter? converter = null;

    try {
      converter = new CharsetConverter("UTF-8", this.encoding);
    } catch (Error err) {
      #if DEBUG
      warning(err.message);
      #endif

      this.transition(this.state, Wrote.DocumentState.NORMAL, false);

    }

    ConverterInputStream converter_input =
      new ConverterInputStream(input, converter);

    this.buffer.text = "";

    Gtk.TextIter end;

    size_t length = 0;
    do {
      try {
        length = yield converter_input.read_async(this.readbuf, Priority.LOW);
      } catch (Error er) {
        length = -1;

        #if DEBUG
        warning(er.message);
        #endif

        this.transition(this.state, Wrote.DocumentState.NORMAL, false);

        if (er is IOError.INVALID_DATA) {
          throw new Wrote.DocumentError.ENCODING_CONVERSION_FAILED(
            "Reading the file “%s” as %s failed.",
            this.file.get_basename(),
            this.encoding);
        } else {
          warning(er.message);
        }
      }

      if (length > 0) {

        if (!((string) this.readbuf).validate((int) length)) {
          #if DEBUG
          warning("Could read the file as %s but it was invalidly converted to UTF-8.", this.encoding);
          #endif

          this.transition(this.state, Wrote.DocumentState.NORMAL, false);

          throw new Wrote.DocumentError.ENCODING_CONVERSION_FAILED(
            "Reading the file “%s” as %s failed.",
            this.file.get_basename(),
            this.encoding);
        }

        this.buffer.get_end_iter(out end);
        this.buffer.insert_text(ref end, (string) this.readbuf, (int) length);

      }

    } while (length > 0);


    this.buffer.set_modified(false);

    this.transition(this.state, Wrote.DocumentState.NORMAL);

    return true;
  }

  public void move(File? to, string? encoding = null) {
    if (to != null) {
      this.file = to;
    }

    if (encoding != null) {
      this.encoding = encoding;
    }
  }

  public async bool save() throws Wrote.DocumentError {
    if (this.file == null)
      return false;

    this.transition(this.state, Wrote.DocumentState.SAVING);

    FileOutputStream? output = null;

    try {
      output = yield this.file.replace_async(
        null,
        true,
        FileCreateFlags.PRIVATE,
        Priority.DEFAULT);
    } catch (Error e) {
      this.transition(this.state, Wrote.DocumentState.NORMAL, false);
      error(e.message);
    }

    CharsetConverter? converter = null;

    try {
      converter = new CharsetConverter(this.encoding, "UTF-8");
    } catch (Error e) {
      this.transition(this.state, Wrote.DocumentState.NORMAL, false);
      error(e.message);
    }

    ConverterOutputStream converted_output = new ConverterOutputStream(output, converter);

    Gtk.TextIter start, end;
    this.buffer.get_start_iter(out start);
    end = start;

    do {
      end = start;
      end.forward_chars(BUFSIZE);

      string text = this.buffer.get_text(start, end, false);

      try {
        yield converted_output.write_async(text.data, Priority.HIGH);
      } catch (Error e) {
        this.transition(this.state, Wrote.DocumentState.NORMAL, false);
        warning(e.message);
      }

      start = end;

    } while (!end.is_end());

    this.buffer.set_modified(false);

    this.transition(this.state, Wrote.DocumentState.NORMAL);

    return true;
  }

  public async bool save_as(File as, string? enc = null) throws Wrote.DocumentError {
    this.move(as, enc);


    bool good = false;

    try {
       good = yield this.save();
    } catch (Wrote.DocumentError e) {
      throw e;
    }

    yield this.query_title();

    return good;
  }

  async void query_title() {
    if (!this.has_file)
      return;

    FileInfo? info = null;

    try {
      info = yield this.file.query_info_async(
        FileAttribute.STANDARD_DISPLAY_NAME,
        FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
        Priority.HIGH,
        null);

      if (info != null) {
        string? dn = info.get_display_name();

        if (dn != null) {
          this.title = info.get_display_name();
        } else {
          warning("Display name for '%s' is null. Using basename from path.",
            this.file.get_uri());

          this.title = Filename.display_basename(this.file.get_path());
        }
      }

    } catch (Error e) {
      warning("Querying display name for '%s' failed. Using basename from path. %s",
        this.file.get_uri(),
        e.message);

      this.title = Filename.display_basename(this.file.get_path());
    }
  }
}
