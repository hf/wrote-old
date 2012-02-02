/*
 * SaveFile.vala
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

public class Wrote.Actions.SaveFile: Gtk.Action, Wrote.Action {

  public string? accelerator { get; protected set; default = "<Control>S"; }

  construct {
    this.stock_id = "gtk-save";
  }

  public SaveFile() {
    Object(name: "SaveFile");
  }

  public override void activate() {
    Wrote.Window window = Wrote.App.window as Wrote.Window;

    if (!window.document.has_file) {
      Wrote.SaveFileDialog sfd = new Wrote.SaveFileDialog();

      sfd.run();
    } else {
      window.document.save.begin((o, r) => {
        try {
          window.document.save.end(r);
        } catch (Wrote.DocumentError e) {
          window.present_error(e);
        }
      });
    }
  }

}
