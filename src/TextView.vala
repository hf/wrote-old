/*
 * TextView.vala
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

public class Wrote.TextView: Gtk.TextView {

  public weak Wrote.Document document { get; construct set; }

  construct {
    this.app_paintable = true;
    this.wrap_mode = Gtk.WrapMode.WORD_CHAR;

    this.width_request = Wrote.Theme.EDITOR_WIDTH;
    this.height_request = Wrote.Theme.EDITOR_HEIGHT;

    this.pixels_inside_wrap = Wrote.Theme.LEADING;
    this.pixels_above_lines = Wrote.Theme.ABOVE_PARAGRAPH;
    this.pixels_below_lines = Wrote.Theme.BELOW_PARAGRAPH;

    this.override_font(Wrote.Theme.regular_font());
    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
  }

  public TextView(Wrote.Document document) {
    Object(document: document, buffer: document.buffer);
  }

  public override bool draw(Cairo.Context ctx) {
    ctx.save();

    // by transforming the pattern matrix to correspond to the pixels
    // above and below this widget ensures smoothness in the transitions
    // make sure you reset the transformation matrix on the pattern after
    // you are done, to the identity matrix!
    Gtk.Allocation alloc;
    this.get_allocation(out alloc);

    Cairo.Matrix imx = Cairo.Matrix.identity();
    Cairo.Matrix mx = imx;

    mx.translate(alloc.x, alloc.y);

    // set transform matrix
    Wrote.Theme.BACKGROUND_PATTERN.set_matrix(mx);

    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);

    ctx.set_operator(Cairo.Operator.SOURCE);

    ctx.paint();

    // unset transform matrix, very important!
    Wrote.Theme.BACKGROUND_PATTERN.set_matrix(imx);

    ctx.restore();

    ctx.save();

    base.draw(ctx);

    ctx.restore();

    return true;
  }
}
