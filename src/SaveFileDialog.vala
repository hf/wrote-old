/*
 * SaveFileDialog.vala
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

public class Wrote.SaveFileDialog: Gtk.FileChooserDialog {

  construct {
    this.action = Gtk.FileChooserAction.SAVE;
    this.title = "Save File…";

    this.add_buttons(
      "gtk-save", Gtk.ResponseType.ACCEPT,
      "gtk-cancel", Gtk.ResponseType.CANCEL);

  }

  public SaveFileDialog(Gtk.Window? parent = null) {
    if (parent != null) {
      this.transient_for = parent;
    } else {
      this.transient_for = Wrote.App.window;
    }
  }

  public override void response(int response) {
    if (response == Gtk.ResponseType.ACCEPT) {
      Wrote.Window window = this.transient_for as Wrote.Window;

      window.document.save_as.begin(this.get_file(), null, (o, r) => {
        try {
          window.document.save_as.end(r);
        } catch (Error e) {
          window.present_error(e);
        }
      });

      this.destroy();
    }
  }
}
