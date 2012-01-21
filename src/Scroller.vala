/*
 * Scroller.vala
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

public enum Wrote.ScrollingDirection {
  VERTICAL,
  HORIZONTAL,
  BOTH
}

public class Wrote.Scroller: Gtk.Overlay {
  public Gtk.Adjustment hadjustment { get; private set; }
  public Gtk.Adjustment vadjustment { get; private set; }

  public Wrote.ScrollingDirection scrolling_direction {
    get;
    set;
    default = Wrote.ScrollingDirection.BOTH;
  }

  construct {
    this.add_events(Gdk.EventMask.SCROLL_MASK);
  }

  public override void get_preferred_width(out int min, out int nat) {
    int rwidth;
    this.get_child().get_size_request(out rwidth, null);

    this.get_child().get_preferred_width(out min, out nat);

    if (this.scrolling_direction == ScrollingDirection.HORIZONTAL ||
        this.scrolling_direction == ScrollingDirection.BOTH)
    {
      min = int.min(min, rwidth.abs());
      nat = min;
    }
  }

  public override void get_preferred_height(out int min, out int nat) {
    int rheight;
    this.get_child().get_size_request(null, out rheight);

    this.get_child().get_preferred_height(out min, out nat);

    if (this.scrolling_direction == ScrollingDirection.VERTICAL ||
        this.scrolling_direction == ScrollingDirection.BOTH)
    {
      min = int.min(min, rheight.abs());
      nat = min;
    }
  }

  public override void size_allocate(Gtk.Allocation allocation) {
    this.set_allocation(allocation);

    Gtk.Allocation child = Gtk.Allocation();

    child.x = allocation.x;
    child.y = allocation.y;
    child.width = allocation.width;
    child.height = allocation.height;

    this.get_child().size_allocate(child);
  }

  public override void add(Gtk.Widget widget)
  requires (widget is Gtk.Scrollable)
  {
    this.hadjustment = (widget as Gtk.Scrollable).hadjustment;
    this.vadjustment = (widget as Gtk.Scrollable).vadjustment;

    this.vadjustment.notify["value"].connect(() => {
      this.queue_draw();
    });

    this.vadjustment.changed.connect(() => {
      this.queue_draw();
    });

    this.hadjustment.notify["value"].connect(() => {
      this.queue_draw();
    });

    this.hadjustment.changed.connect(() => {
      this.queue_draw();
    });

    base.add(widget);
  }

  public override bool scroll_event(Gdk.EventScroll event) {

    // even seems to do a better job at scrolling without artifacts
    if (this.vadjustment.step_increment % 2 != 0)
      this.vadjustment.step_increment++;

    switch (event.direction) {
      case Gdk.ScrollDirection.UP:
        this.vadjustment.value -= this.vadjustment.step_increment;
        break;

      case Gdk.ScrollDirection.DOWN:
        this.vadjustment.value += this.vadjustment.step_increment;
        break;

      case Gdk.ScrollDirection.LEFT:
        this.hadjustment.value -= this.hadjustment.step_increment;
        break;

      case Gdk.ScrollDirection.RIGHT:
        this.hadjustment.value += this.hadjustment.step_increment;
        break;
    }

    return true;
  }
}
