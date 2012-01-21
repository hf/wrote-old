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

  public bool modified {
    get {
      return this.buffer.get_modified();
    }

    private set {
      this.buffer.set_modified(value);
    }
  }

  construct {
    this.buffer = new Wrote.TextBuffer();

    this.buffer.modified_changed.connect(() => {
      this.notify["modified"];
    });
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
