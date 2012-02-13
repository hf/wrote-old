/*
 * Status.vala
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

enum Animation {
  FADE_IN,
  FADE_OUT
}

public class Wrote.Status: Gtk.Label {
  static const double ANGLE_STEP = 0.1;
  static const uint PUSH_TIME = 3000;
  static const uint ANIM_TIME = 40;

  public weak Wrote.Document document { get; construct set; }

  private uint push_timeout = 0;

  private uint animation_source = 0;

  private Animation animation = Animation.FADE_OUT;
  private double animation_angle = Math.PI_2;

  construct {
    this.document.buffer.notify["words"].connect(() => {
      if (this.push_timeout == 0) {
        this.normal();
      }
    });

    this.document.buffer.notify["chars"].connect(() => {
      if (this.push_timeout == 0) {
        this.normal();
      }
    });

    this.normal();

    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
  }

  public Status(Wrote.Document d) {
    Object(document: d);
  }

  public void push(string text, uint timeout = PUSH_TIME) {
    this.label = text;

    if (this.push_timeout != 0) {
      Source.remove(this.push_timeout);
    }

    this.push_timeout = Timeout.add(timeout, () => {
      this.normal();

      return false;
    });
  }

  public override bool draw(Cairo.Context ctx) {
    base.draw(ctx);

    double opacity = Math.sin(this.animation_angle);

    ctx.save();

    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);

    ctx.set_operator(Cairo.Operator.SOURCE);

    ctx.paint_with_alpha(opacity);

    ctx.restore();

    return false;
  }

  public void fade() {
    if (this.animation_source != 0) {
      Source.remove(this.animation_source);
      this.animation_source = 0;
    }

    if (this.animation == Animation.FADE_IN) {
      this.animation = Animation.FADE_OUT;
    } else {
      this.animation = Animation.FADE_IN;
    }

    this.animation_source = Timeout.add(ANIM_TIME, this.animate);
  }

  public void normal() {
    if (this.push_timeout != 0) {
      Source.remove(this.push_timeout);
      this.push_timeout = 0;
    }

    this.label = "%d Words / %d Characters".printf(
      this.document.buffer.words,
      this.document.buffer.chars);
  }

  bool animate() {
    bool done = false;

    if (this.animation == Animation.FADE_OUT) {
      this.animation_angle += ANGLE_STEP;

      if (this.animation_angle > Math.PI_2) {
        this.animation_angle = Math.PI_2;
        done = true;
      }
    } else {
      this.animation_angle -= ANGLE_STEP;

      if (this.animation_angle < 0) {
        this.animation_angle = 0;
        done = true;
      }
    }

    this.queue_draw();

    return !done;
  }
}
