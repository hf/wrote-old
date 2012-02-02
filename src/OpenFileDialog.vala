/*
 * OpenFileDialog.vala
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

namespace Wrote.FileFilters {
  public static Gtk.FileFilter All() {
    Gtk.FileFilter all_ff = new Gtk.FileFilter();

    all_ff.set_filter_name("All Files");

    all_ff.add_custom(
      Gtk.FileFilterFlags.FILENAME | Gtk.FileFilterFlags.URI |
      Gtk.FileFilterFlags.DISPLAY_NAME | Gtk.FileFilterFlags.MIME_TYPE,
      (fi) => {
        Gtk.FileFilter txt = Wrote.FileFilters.Text();
        Gtk.FileFilter mkd = Wrote.FileFilters.Markdown();

        return txt.filter(fi) || mkd.filter(fi);
      });

    return all_ff;
  }

  public static Gtk.FileFilter Text() {
    Gtk.FileFilter text_ff = new Gtk.FileFilter();

    text_ff.set_filter_name("Text Files");

    text_ff.add_mime_type("plain/text");
    text_ff.add_pattern("*.text");
    text_ff.add_pattern("*.txt");
    text_ff.add_pattern("*.wrote");

    return text_ff;
  }

  public static Gtk.FileFilter Markdown() {
    Gtk.FileFilter md_ff = new Gtk.FileFilter();

    md_ff.set_filter_name("Markdown Files");

    md_ff.add_mime_type("text/x-markdown");
    md_ff.add_pattern("*.md");
    md_ff.add_pattern("*.markdown");

    return md_ff;
  }
}

public class Wrote.OpenFileDialog: Gtk.FileChooserDialog {

  public Wrote.EncodingComboBox encodings { get; private set; }

  private Gtk.Label encodings_label;
  private Gtk.Box container;
  private Gtk.Expander expander;

  construct {
    this.title = "Open file…";
    this.action = Gtk.FileChooserAction.OPEN;

    this.transient_for = Wrote.App.window;

    this.add_filter(Wrote.FileFilters.All());
    this.add_filter(Wrote.FileFilters.Text());
    this.add_filter(Wrote.FileFilters.Markdown());

    this.add_buttons(
      "gtk-open", Gtk.ResponseType.ACCEPT,
      "gtk-cancel", Gtk.ResponseType.CANCEL);

    this.encodings = new Wrote.EncodingComboBox();

    this.encodings_label = new Gtk.Label("Encoding:");

    this.expander = new Gtk.Expander("More Options");
    this.expander.resize_toplevel = true;
    this.expander.expanded = false;

    this.container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

    this.container.pack_start(this.encodings_label, false, false, 4);
    this.container.pack_start(this.encodings, true, true, 4);

    this.expander.add(this.container);

    this.container.margin_left = 10;
    this.container.margin_right = 10;

    Gtk.Box content_area = this.get_content_area() as Gtk.Box;

    content_area.pack_start(this.expander, false, false, 0);

    this.expander.margin_right = this.expander.margin_left = 5;
    this.expander.margin_bottom = 20;
  }

  public override void show() {
    base.show();

    Gtk.Box content_area = this.get_content_area() as Gtk.Box;
    content_area.show_all();
  }

  public override void response(int response) {
    if (response == Gtk.ResponseType.ACCEPT) {
      Wrote.Window window = this.transient_for as Wrote.Window;

      window.document.move(this.get_file(), this.encodings.canonical_encoding);

      window.document.load.begin((o, r) => {
        try {
          window.document.load.end(r);
        } catch (Error e) {
          window.present_error(e);
        }
      });
    }

    this.destroy();
  }
}
