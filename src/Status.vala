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
using Cairo;

using Wrote;

enum Animation {
  FADE_IN,
  FADE_OUT
}

public class Wrote.Status: Gtk.Label {
  public weak Wrote.Document document { get; construct set; }

  private double animation_angle = 0.0;
  private uint animation = 0;
  private Animation animation_state = Animation.FADE_OUT;

  construct {
    this.app_paintable = true;

    this.document.buffer.notify["chars"].connect(() => {
      this.label = this.words_and_char_count();
    });

    this.label = this.words_and_char_count();

    this.show.connect(() => {
      this.toggle_fade();
    });
  }

  public Status(Wrote.Document document) {
    Object(document: document);
  }

  public override bool draw(Cairo.Context cr) {
    base.draw(cr);

    cr.save();

    cr.set_source(Wrote.Theme.BACKGROUND_PATTERN);

    Gtk.Allocation allocation;

    this.get_allocation(out allocation);

    Cairo.Matrix matrix = Cairo.Matrix.identity();
    matrix.translate(allocation.x, allocation.y);

    cr.set_matrix(matrix);

    cr.paint_with_alpha(1 - Math.sin(this.animation_angle));

    cr.restore();

    cr.set_matrix(Cairo.Matrix.identity());

    return false;
  }

  public void toggle_fade() {
    if (this.animation == 0) {
      this.animation = Timeout.add(60, this.animate);
    }

    if (this.animation_state == Animation.FADE_OUT) {
       this.animation_state = Animation.FADE_IN;
    } else {
       this.animation_state = Animation.FADE_OUT;
    }
  }

  public void fade_in() {
    if (this.animation_state == Animation.FADE_OUT) {
      this.toggle_fade();
    }
  }

  public void fade_out() {
    if (this.animation_state == Animation.FADE_IN) {
      this.toggle_fade();
    }
  }

  private string words_and_char_count() {
    return "%d words / %d chars".printf(this.document.buffer.words, this.document.buffer.chars);
  }

  private bool animate() {
    this.queue_draw();

    if (this.animation_state == Animation.FADE_IN) {
      this.animation_angle += 0.08;

      if (this.animation_angle >= Math.PI_2) {
        this.animation = 0;
        this.animation_angle = Math.PI_2;

        return false;
      }
    } else {
      this.animation_angle -= 0.1;

      if (this.animation_angle <= 0.0) {
        this.animation = 0;
        this.animation_angle = 0;

        return false;
      }
    }

    return true;
  }
}
