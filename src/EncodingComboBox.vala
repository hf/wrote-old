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

namespace Wrote.Encoding {

  public static const string UNICODE_REGEX = "(UTF-8|UTF8|Unicode)";
  public static const string WESTERN_REGEX = "(ISO-*)?8859-?2";

  /* tests whether input describes UTF8 according to UTF8_REGEX! */
  public static bool is_unicode(string input) {
    return Regex.match_simple(UNICODE_REGEX, input,
      RegexCompileFlags.CASELESS | RegexCompileFlags.MULTILINE);
  }

  public static bool is_western(string input) {
    return Regex.match_simple(WESTERN_REGEX, input,
      RegexCompileFlags.CASELESS | RegexCompileFlags.MULTILINE);
  }

}

public class Wrote.EncodingComboBox: Gtk.ComboBox {

  public string encoding {
    get {
      Gtk.TreeIter i;
      this.get_active_iter(out i);

      unowned string id;
      this.model.get(i, 0, out id, -1);

      return id;
    }
  }

  public string encoding_name {
    get {
      Gtk.TreeIter i;
      this.get_active_iter(out i);

      unowned string encoding;
      this.model.get(i, 1, out encoding, -1);

      return encoding;
    }
  }

  construct {
    this.model = new Gtk.ListStore(2, typeof(string), typeof(string));

    this.entry_text_column = 1;

    Gtk.TreeIter i;

    (this.model as Gtk.ListStore).append(out i);
    (this.model as Gtk.ListStore).set(i, 0, "UTF-8", 1, "Unicode (UTF-8)", -1);

    this.set_active_iter(i);

    (this.model as Gtk.ListStore).append(out i);
    (this.model as Gtk.ListStore).set(i, 0, "ISO-8859-2", 1, "Western (ISO 8859-2)", -1);

    Gtk.Entry entry = this.get_child() as Gtk.Entry;

    entry.activate.connect(() => {
      this.add(entry.text);
    });
  }

  public EncodingComboBox() {
    Object(has_entry: true, id_column: 0);
  }

  public new void add(string input) {
    if (Wrote.Encoding.is_unicode(input)) {
      this.set_active_id("UTF-8");
      return;
    }

    if (Wrote.Encoding.is_western(input)) {
      this.set_active_id("ISO88592");
      return;
    }

    bool has = false;

    (this.model as Gtk.ListStore).foreach((m, p, i) => {

      string? id, encoding;

      (this.model as Gtk.ListStore).get(i, 0, out id, 1, out encoding, -1);

      if ((input.length >= encoding.length || input.length >= id.length) &&
          (input.contains(encoding) || input.contains(id)))
      {
        this.set_active_id(id);
        has = true;
      }

      return has;
    });

    if (!has) {
      string normalized = input.strip();

      Gtk.TreeIter i;
      (this.model as Gtk.ListStore).append(out i);
      (this.model as Gtk.ListStore).set(i, 0, normalized, 1, normalized, -1);
      this.set_active_id(normalized);

      // FIXME: Check if the input encoding can be converted to and from UTF-8
    }

  }

  public void done() {
    this.add((this.get_child() as Gtk.Entry).text);
  }
}
