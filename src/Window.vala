/*
 * Window.vala
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

public class Wrote.Window: Gtk.Window {

  public Wrote.Document document { get; construct set; }

  // UI
  public Gtk.Box container { get; private set; }

  public Wrote.Scroller scroller { get; private set; }
  public Wrote.TextView text_view { get; private set; }

  public Window(Wrote.Document doc) {
    Object(document: doc);
  }

  construct {
    this.application = Wrote.App;

    this.app_paintable = true;

    this.make_title(true);

    this.default_width = Wrote.Theme.WIDTH;
    this.default_height = Wrote.Theme.HEIGHT;

    this.container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    this.scroller = new Wrote.Scroller();
    this.text_view = new Wrote.TextView(this.document);

    this.scroller.add(this.text_view);

    this.container.pack_start(this.scroller, true, true, 0);

    this.scroller.halign = Gtk.Align.CENTER;
    this.scroller.margin_top = Wrote.Theme.MARGIN_TOP;
    this.scroller.margin_bottom = Wrote.Theme.MARGIN_BOTTOM;
    this.scroller.margin_left = Wrote.Theme.MARGIN_LEFT;
    this.scroller.margin_right = Wrote.Theme.MARGIN_RIGHT;

    this.add(this.container);
  }

  public override bool draw(Cairo.Context ctx) {
    ctx.save();

    ctx.save();

    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);

    ctx.set_operator(Cairo.Operator.SOURCE);

    ctx.paint();

    ctx.restore();

    ctx.save();

    base.draw(ctx);

    ctx.restore();

    return true;
  }

  void make_title(bool start_watching = false) {
    this.title = (this.document.modified ? "*" : "") + this.document.title;

    if (start_watching) {
      this.document.notify["modified"].connect(() => {
        this.make_title();
      });
    }
  }
}
