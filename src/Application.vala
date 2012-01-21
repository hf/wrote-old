/*
 * Application.vala
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

namespace Wrote {
  public static Wrote.Application? App = null;
}

public class Wrote.Application: Gtk.Application {

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

  public Application() {
    Object(application_id: "org.wrote.Wrote");
  }

  ~Application() {
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
    Wrote.App = new Wrote.Application();

    return Wrote.App.run(args);
  }

  public Wrote.Window open_document(File? file = null) {
    Wrote.Document document = new Wrote.Document(file);
    document.load.begin();

    Wrote.Window window = new Wrote.Window(document);

    window.show_all();

    return window;
  }
}
