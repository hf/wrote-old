/*
 * EncodingComboBox.vala
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

using Wrote;

public enum Wrote.Encoding {
  UTF8,
  ISO_8859_1,
  OTHER
}

namespace Wrote.Encodings {
  public static const string UTF8 = "Unicode (UTF-8)";
  public static const string ISO_8859_1 = "Western (ISO 8859-1)";

  public static const string UTF8_C = "UTF-8";
  public static const string ISO_8859_1_C = "8859-1";
}

public class Wrote.EncodingComboBox: Gtk.ComboBoxText {

  public Wrote.Encoding encoding {
    get {
      if (this.get_active() == 0) {
        return Wrote.Encoding.UTF8;
      } else if (this.get_active() == 1) {
        return Wrote.Encoding.ISO_8859_1;
      }

      return Wrote.Encoding.OTHER;
    }
  }

  public string encoding_string {
    get {
      if (this.encoding == Wrote.Encoding.UTF8) {
        return Wrote.Encodings.UTF8;

      } else if (this.encoding == Wrote.Encoding.ISO_8859_1) {
        return Wrote.Encodings.ISO_8859_1;
      }

      return this.get_active_text();
    }

    set {
      string val = value.strip();
      string valcmp = val.casefold();

      if (valcmp.contains(Wrote.Encodings.UTF8_C.casefold())) {
        this.active = 0;
      } else if (valcmp.contains(Wrote.Encodings.ISO_8859_1_C.casefold())) {
        this.active = 1;
      } else {
        int pe = this.has_encoding(val);

        if (pe < 0) {
          items++;
          this.append_text(val);
          this.active = items;
        } else {
          this.active = pe;
        }
      }
    }
  }

  public string canonical_encoding {
    get {
      if (this.encoding == Wrote.Encoding.UTF8) {
        return "UTF-8";
      } else if (this.encoding == Wrote.Encoding.ISO_8859_1) {
        return "ISO-8859-1";
      }

      return this.encoding_string;
    }
  }

  private int items = 0;

  public EncodingComboBox() {
    Object(has_entry: true);
  }

  construct {
    this.entry_text_column = 1;

    this.append_text(Wrote.Encodings.UTF8);
    this.append_text(Wrote.Encodings.ISO_8859_1);

    this.items++;

    this.active = 0;

    Gtk.Entry entry = this.get_child() as Gtk.Entry;

    entry.activate.connect(() => {
      this.encoding_string = entry.get_text();
    });
  }

  int has_encoding(string enc) {
    string estr = enc.strip();
    estr = estr.casefold();

    Gtk.TreePath? path = null;

    this.model.foreach((m, p, i) => {

      string? ival = null;

      this.model.get(i, 1, out ival);

      ival = ival.casefold();

      if (ival.contains(estr)) {
        path = this.model.get_path(i);

        return true;
      }

      return false;
    });

    if (path != null && path.get_depth() >= 1) {
      int[] indices = path.get_indices();
      return indices[0];
    }

    return -1;
  }
}
